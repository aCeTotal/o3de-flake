{
  description = "O3DE Game Engine flake with customizable source";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    pyproject-nix.url = "github:pyproject-nix/pyproject.nix/af4c3cc";
    flake-utils.url = "github:numtide/flake-utils";

    fork = {
      url = "github:o3de/o3de";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, pyproject-nix, flake-utils, fork, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
        python = pkgs.python311;

        pythonEnv = import ./o3de-packages/python.nix {
          inherit pkgs python pyproject-nix;
        };
      in {
        packages.default = pkgs.stdenv.mkDerivation {
          pname = "o3de";
          version = "dev";
          src = fork;

          nativeBuildInputs = [
            pythonEnv
            pkgs.cmake
            pkgs.ninja
            pkgs.git
            pkgs.pkg-config
          ];

          buildInputs = [
            pythonEnv
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
            echo "Python version: $(python3 --version)"
            cmake -B build -S . -GNinja
          '';

          buildPhase = "ninja -C build";

          installPhase = ''
            mkdir -p $out
            cp -r build/bin $out/
          '';
        };

        devShells.default = pkgs.mkShell {
          packages = [
            pythonEnv
            pkgs.cmake
            pkgs.ninja
            pkgs.clang_16
            pkgs.git
          ];

          shellHook = ''
            echo "✅ O3DE devShell aktivert"
            echo "Python: $(which python3)"
          '';
        };
      });
}

