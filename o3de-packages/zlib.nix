{ pkgs }:

pkgs.stdenv.mkDerivation rec {
  pname = "zlib-1.2.11-rev5-linux";
  version = "1.2.11";

  src = pkgs.fetchurl {
    url = "https://d3t6xeg4fgfoum.cloudfront.net/${pname}.tar.xz";
    sha256 = "m+XqhXIvwnqGRanIqBJmnRB8aOa6osoHQIcurraosPw=";
  };

  unpackPhase = ''
    runHook preUnpack

    pkgdir=$out/packages/${pname}
    mkdir -p $pkgdir/include $pkgdir/lib

    tar -xf $src -C $pkgdir

    echo "Files in $pkgdir:"
    find $pkgdir

    # Lag hash.sha256 for O3DE-verifikasjon
    cat > $pkgdir/3rdPartyPackageManifest.json <<EOF
{
  "source": "custom",
  "version": "${version}",
  "name": "zlib",
  "platform": "linux",
  "hashAlgorithm": "sha256"
}
EOF

    cd $pkgdir
    sha256sum 3rdPartyPackageManifest.json | cut -d' ' -f1 > hash.sha256

    runHook postUnpack
  '';

  buildPhase = "true";
  installPhase = "true";
}

