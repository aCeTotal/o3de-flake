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

  unpackPhase = ''
    mkdir source
    tar -xJf ${qtTarball} -C source
  '';

  installPhase = ''
    mkdir -p $out/packages/qt-5.15.2-rev9-linux
    cp -a source/. $out/packages/qt-5.15.2-rev9-linux

    # Flytt SHA256SUMS som "hash.sha256"
    cp $out/packages/qt-5.15.2-rev9-linux/SHA256SUMS \
       $out/packages/qt-5.15.2-rev9-linux/hash.sha256

    # Lag stempelfil for å hindre nedlasting
    touch $out/packages/qt-5.15.2-rev9-linux.stamp
  '';
}

