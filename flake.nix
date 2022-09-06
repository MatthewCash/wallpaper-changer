{
    description = "Gnome Wallpaper Changer";

    inputs = {
        nixpkgs.url = "nixpkgs/nixos-unstable";
        flake-utils.url = "github:numtide/flake-utils";
    };

    outputs = inputs @ { self, nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
        let pkgs = nixpkgs.legacyPackages.${system}; in rec {
            devShell = pkgs.mkShell rec {
                name = "wp-changer";
                packages = with pkgs; [
                    glib
                    pkg-config
                ];
                CPATH = builtins.concatStringsSep ":" [
                    "${pkgs.glib.dev}/include/glib-2.0"
                    "${pkgs.glib.out}/lib/glib-2.0/include/"
                ];
            };
            defaultPackage = pkgs.stdenv.mkDerivation {
                name = "wp-changer";

                nativeBuildInputs = with pkgs; [ pkg-config ];

                buildInputs = with pkgs; [ glib ];

                src = ./.;

                installPhase = ''
                    mkdir -p $out/bin
                    cp bin/* $out/bin/
                '';
            };
        }
    );
}
