{ pkgs ? import <nixpkgs> { } }:

let
  mach-nix = import (builtins.fetchTarball {
    url = "https://github.com/DavHau/mach-nix/archive/refs/tags/3.5.0.tar.gz";
    sha256 = "sha256:185qf6d5xg8qk1hb1y0b5gggr71vdz8v9d5ga4zg7dmcb1aypxcg";
  }) {
    inherit pkgs;
  };

  pythonEnv = mach-nix.mkPython {
    python = "python311";  # <-- må være string
    requirements = builtins.readFile ./requirements.txt;
  };

in {
  o3dePython = pythonEnv;
}

