{ pkgs }:

pkgs.stdenv.mkDerivation rec {
  pname = "qt-5.15.2-rev9-linux";
  version = "5.15.2";

  src = pkgs.fetchurl {
    url = "https://d3t6xeg4fgfoum.cloudfront.net/${pname}.tar.xz";
    sha256 = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="; # <-- Midlertidig placeholder
  };

  nativeBuildInputs = [ pkgs.gnutar pkgs.xz ];

  unpackPhase = ''
    runHook preUnpack
    mkdir -p $out/packages
    tar -xf $src -C $out/packages
    runHook postUnpack
  '';

  buildPhase = ''
    echo "📦 Innhold i pakken:"
    find $out/packages/${pname} || true

    # Legg til hash.sha256 hvis den mangler
    if [ ! -f "$out/packages/${pname}/hash.sha256" ]; then
      echo "⚠️  Genererer manglende hash.sha256..."
      (
        cd $out/packages/${pname}
        sha256sum 3rdPartyPackageManifest.json | cut -d' ' -f1 > hash.sha256
      )
    fi
  '';

  installPhase = "true";
}

