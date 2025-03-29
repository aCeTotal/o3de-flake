{
  description = "O3DE Game Engine flake with locked Python module and dependencies";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    pyproject-nix.url = "github:pyproject-nix/pyproject.nix/af4c3cc";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, pyproject-nix, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
        python = pkgs.python311;

        o3deSrc = pkgs.fetchgit {
          url = "https://github.com/aCeTotal/o3de.git";
          rev = "660b410";
          sha256 = "sha256-660b4109970883ce7da9ea2ca82a29f217096921";
          fetchLFS = true;
        };

        o3dePythonLib = python.pkgs.buildPythonPackage {
          pname = "o3de";
          version = "1.0.0";
          format = "setuptools";
          src = "${o3deSrc}/scripts/o3de";
          doCheck = false;

          propagatedBuildInputs = [ ];

          meta = {
            description = "O3DE editor Python bindings";
            homepage = "https://github.com/o3de/o3de";
            license = pkgs.lib.licenses.asl20;
          };
        };

        pythonEnv = python.withPackages (ps:
          [
            o3dePythonLib
            (import ./o3de-packages/python.nix {
              inherit pkgs python pyproject-nix;
              fork = o3deSrc;
            })
          ]
        );

      in {
        packages.default = pkgs.stdenv.mkDerivation {
          pname = "o3de";
          version = "dev";
          src = o3deSrc;

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
            echo "🔧 Python version: $(python3 --version)"
            export LY_3RDPARTY_PATH="$TMPDIR/fake-3rdparty"
            mkdir -p "$LY_3RDPARTY_PATH"

            cmake -B build/linux -S ${o3deSrc} \
              -G "Ninja Multi-Config" \
              -DLY_3RDPARTY_PATH="$LY_3RDPARTY_PATH"
          '';

          buildPhase = ''
            cmake --build build/linux --target Editor --config profile -j$(nproc)
          '';

          installPhase = ''
            mkdir -p $out
            cp -r build/linux/bin/profile $out/
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

