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
          sha256 = "sha256-AVF5d8dX/obn35xrFBZNItRlHCCFuF8nEPOfX1JuOpY=";
          fetchLFS = true;
        };

        zlibPackage = import ./o3de-packages/zlib.nix { inherit pkgs; };
        qtPackage = import ./o3de-packages/qt.nix { inherit pkgs; };

        thirdPartyPath = pkgs.runCommand "o3de-3rdparty-path" { } ''
          mkdir -p $out/packages

          # Kopier Zlib
          cp -r ${zlibPackage}/packages/zlib-* $out/packages/

          # Kopier Qt
          cp -r ${qtPackage}/packages/qt-5.15.2-rev9-linux $out/packages/

          # Lag .stamp-filer
          touch $out/packages/zlib-1.2.11-rev5-linux.stamp
          touch $out/packages/qt-5.15.2-rev9-linux.stamp
        '';

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

        pythonEnv = python.withPackages (ps: [
          o3dePythonLib
          (import ./o3de-packages/python.nix {
            inherit pkgs python pyproject-nix;
            fork = o3deSrc;
          })
        ]);

      in {
        packages = {
          default = pkgs.stdenv.mkDerivation {
            pname = "o3de";
            version = "dev";
            src = o3deSrc;

            nativeBuildInputs = [
              pythonEnv
              pkgs.cmake
              pkgs.clang
              pkgs.ninja
              pkgs.git
              pkgs.pkg-config
            ];

            buildInputs = [
              pythonEnv
              zlibPackage
              qtPackage

              pkgs.clang
              pkgs.clang.cc
              pkgs.clang_16
              pkgs.gcc12.cc.lib
              pkgs.vulkan-loader
              pkgs.vulkan-headers
              pkgs.mesa
              pkgs.libGL
              pkgs.libunwind
              pkgs.zstd

              pkgs.xorg.libX11
              pkgs.xorg.libXcursor
              pkgs.xorg.libXi
              pkgs.xorg.libXrandr
              pkgs.xorg.libXxf86vm
              pkgs.xorg.libXinerama
              pkgs.xorg.libXrender
              pkgs.libxkbcommon

              pkgs.xorg.xcbutil
              pkgs.xorg.xcbutilkeysyms
              pkgs.xorg.xcbutilwm
              pkgs.xorg.xcbutilimage
              pkgs.xcb-util-cursor
              pkgs.xorg.libxcb

              pkgs.fontconfig
              pkgs.pcre2
              pkgs.tcl
              pkgs.tk
              pkgs.tclPackages.tix
            ];

            configurePhase = ''
              export HOME=$TMPDIR/home
              mkdir -p "$HOME/.o3de"
              echo '{}' > "$HOME/.o3de/o3de_manifest.json"

              export LY_ROOT_FOLDER=$PWD
              export LY_3RDPARTY_PATH="${thirdPartyPath}"
              export O3DE_SKIP_PACKAGE_SERVER_VALIDATION=1
              export LY_DISABLE_PACKAGE_DOWNLOADS=ON

              echo "📦 Innhold i LY_3RDPARTY_PATH:"
              find "$LY_3RDPARTY_PATH" -type f

              cmake -B build/linux -S $LY_ROOT_FOLDER \
                -G "Ninja Multi-Config" \
                -DCMAKE_C_COMPILER=${pkgs.clang}/bin/clang \
                -DCMAKE_CXX_COMPILER=${pkgs.clang}/bin/clang++ \
                -DLY_ROOT_FOLDER=$LY_ROOT_FOLDER \
                -DLY_3RDPARTY_PATH=$LY_3RDPARTY_PATH \
                -DBUILD_PREBUILT_PACKAGE_SUPPORT=OFF \
                -DLY_DISABLE_PACKAGE_DOWNLOADS=ON \
                -DLY_PACKAGE_VALIDATE_CONTENTS=ON \
                -DLY_UNITY_BUILD=OFF \
                -DLY_PACKAGE_DEBUG=ON
            '';

            buildPhase = ''
              cmake --build build/linux --target Editor --config profile -j$(nproc)
            '';

            installPhase = ''
              mkdir -p $out
              cp -r build/linux/bin/profile $out/
            '';
          };

          zlibPackage = zlibPackage;
          qtPackage = qtPackage;
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
            echo "O3DE devShell aktivert"
            echo "Python: $(which python3)"
          '';
        };
      });
}

