{ pkgs }:

let
  pythonTarball = pkgs.fetchurl {
    url = "https://d3t6xeg4fgfoum.cloudfront.net/python-3.10.13-rev2-linux.tar.xz";
    sha256 = "p4MvkXCjrJP75njps9mal32qA7tmfSWIWWfotJd7hvg=";
  };
in

pkgs.stdenv.mkDerivation {
  pname = "python-3.10.13-rev2-linux";
  version = "3.10.13";

  src = pythonTarball;

  nativeBuildInputs = [ pkgs.xz pkgs.gnutar pkgs.patchelf ];

  dontPatchShebangs = true;
  dontFixup = true;

  unpackPhase = ''
    mkdir source source-clean
    tar -xJf $src -C source
    cp -r source/* source-clean/
  '';

  patchPhase = ''
  patchelf \
    --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
    --set-rpath "${pkgs.stdenv.cc.libc}/lib:${pkgs.zlib}/lib" \
    source/python/bin/python
'';

  installPhase = ''
    mkdir -p $out/packages
    cp -r source $out/packages/python-3.10.13-rev2-linux
  '';
}

