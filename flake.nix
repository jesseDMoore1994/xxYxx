{
  description = "xxYxx";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
    utils.url = "github:numtide/flake-utils";
    libsoundio.url = "github:jesseDMoore1994/libsoundio-nix";
  };

  outputs = { self, nixpkgs, libsoundio, ... }@inputs: inputs.utils.lib.eachSystem [
    "x86_64-linux" "i686-linux" "aarch64-linux" "x86_64-darwin"
  ] (system: let pkgs = import nixpkgs {
        inherit system;
      };
      xxYxx = pkgs.stdenv.mkDerivation {
        pname = "xxYxx";
        version = "0.1.0";
        src = ./.;
        nativeBuildInputs = [
          pkgs.gnumake
          pkgs.clang
          pkgs.clang-tools
          pkgs.valgrind
          libsoundio.packages.${system}.libsoundio.out
        ];
        propigatedBuildInputs = [
          pkgs.pkg-config
        ];
        buildPhase = "make && valgrind --leak-check=yes ./dist/test";
        installPhase = ''
          mkdir -p $out/bin $out/lib
          mv dist/test $out/bin
          mv dist/strlib.so $out/lib
        '';
      };
  in rec {
    defaultApp = inputs.utils.lib.mkApp { drv = defaultPackage; };
    defaultPackage = xxYxx;
    libsound = libsoundio.packages.${system}.libsoundio.out;
    devShell = pkgs.mkShell {
      buildInputs = [ pkgs.valgrind pkgs.clang libsoundio.packages.${system}.libsoundio pkgs.pkg-config ];
    };
  });
}
