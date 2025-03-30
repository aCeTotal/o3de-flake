{ pkgs }:

let
  qtTarball = pkgs.fetchurl {
    url = "https://d3t6xeg4fgfoum.cloudfront.net/qt-5.15.2-rev9-linux.tar.xz";
    sha256 = "20vNIAMmL02MfX2oMnWIJPwk5T2liV7e90P2emSlxzQ=";
  };
in

pkgs.stdenv.mkDerivation {
  pname = "qt-5.15.2-rev9-linux";
  version = "5.15.2";

  src = qtTarball;

  nativeBuildInputs = [ pkgs.xz pkgs.gnutar ];

  dontPatchShebangs = true;
  dontFixup = true;

  unpackPhase = ''
    mkdir source source-clean
    tar -xJf ${qtTarball} -C source
    cp -r source/* source-clean/
  '';

  patchPhase = ''
  '';

  installPhase = ''
    mkdir -p $out/packages
    cp -r source $out/packages/qt-5.15.2-rev9-linux
  '';
}

