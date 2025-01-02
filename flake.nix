{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
  };

  outputs = {self, nixpkgs, flake-utils}:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
      version = "0.0.1";
      src = ./.;
      kernel = pkgs.linuxPackages.kernel;
    in
    {
      packages.${system}.default = pkgs.stdenv.mkDerivation {
        pname = "foo";
        inherit version;
        inherit src;

        buildInputs = [
          pkgs.linuxPackages.kernel
        ];

        buildPhase = ''
          make -C ${kernel.dev}/lib/modules/${kernel.version}/build M=$PWD modules
        '';

        installPhase = ''
          mkdir -p $out/lib/modules/${kernel.version}/extra
          cp *.ko $out/lib/modules/${kernel.version}/extra
        '';

        meta = with pkgs.lib; {
          description = "Custom linux kernel module";
          license = licenses.gpl3;
          maintainers = [ maintainers.brennan-seymour ];
        };


      };

    };
}