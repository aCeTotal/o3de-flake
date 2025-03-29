{
  description = "O3DE Game Engine flake with customizable source";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    fork = {
    url = "github:o3de/o3de";
    flake = false;
    };

    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, fork, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
        };

        o3dePackages = import ./o3de-packages/python.nix { inherit pkgs; };
        o3de-src = fork;

        cmakeFlags = [
          "-DLY_3RDPARTY_PATH=${pkgs.stdenv.mkDerivation {
            name = "o3de-3rdparty";
            src = null;
            installPhase = "mkdir -p $out";
          }}"
        ];
      in {
        packages.default = pkgs.stdenv.mkDerivation {
          pname = "o3de";
          version = "dev";
          src = o3de-src;

          nativeBuildInputs = [
            o3dePackages.o3dePython
            pkgs.cmake
            pkgs.ninja
            pkgs.git
            pkgs.pkg-config
          ];

          buildInputs = [
            o3dePackages.o3dePython

            pkgs.clang_16
            pkgs.libstdcxx-12

            pkgs.vulkan-loader
            pkgs.vulkan-headers
            pkgs.mesa
            pkgs.libGL
            pkgs.libunwind
            pkgs.zlib
            pkgs.zstd

            pkgs.xorg.libX11
            pkgs.xorg.libXcursor
            pkgs.xorg.libXi
            pkgs.xorg.libXrandr
            pkgs.xorg.libXxf86vm
            pkgs.xorg.libXinerama
            pkgs.xorg.libXrender

            pkgs.libxkbcommon
            pkgs.libxkbcommon.dev
            pkgs.libxkbcommon-x11
            pkgs.libxkbcommon-x11.dev

            pkgs.xcbutil
            pkgs.xcbutilkeysyms
            pkgs.xcbutilwm
            pkgs.xcbutilimage
            pkgs.xcbutilcursor

            pkgs.xorg.libxcb
            pkgs.xorg.libxcb.dev
            pkgs.xorg.libxcb.lib
            pkgs.xorg.libxcb.out

            pkgs.xorg.libxcbRandr
            pkgs.xorg.libxcbXinerama
            pkgs.xorg.libxcbXinput
            pkgs.xorg.libxcbXfixes

            pkgs.fontconfig
            pkgs.pcre2

            pkgs.tcl
            pkgs.tk
            pkgs.tclPackages.tix
          ];

          configurePhase = ''
            echo "✅ Python versjon: $(python3 --version)"
            cmake -B build -S . \
              -GNinja \
              ${builtins.concatStringsSep " \\\n" cmakeFlags}
          '';

          buildPhase = "ninja -C build";

          installPhase = ''
            mkdir -p $out
            cp -r build/bin $out/
          '';
        };

        devShells.default = pkgs.mkShell {
          packages = [
            o3dePackages.o3dePython
            pkgs.cmake
            pkgs.ninja
            pkgs.clang_16
            pkgs.git
          ];

          shellHook = ''
            echo "O3DE devShell"
            echo "Python: $(which python3)"
          '';
        };
      });
}

