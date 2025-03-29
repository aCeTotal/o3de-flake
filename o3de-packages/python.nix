{ pkgs }:

let
  requirements = import ./requirements.nix;

  inherit (pkgs) fetchPypi python3;

  # Vi bygger hver pakke fra PyPI og pins
  builtPackages = map (pkg:
    python3.pkgs.buildPythonPackage {
      pname = pkg.pname;
      version = pkg.version;
      format = "setuptools";

      src = fetchPypi {
        inherit (pkg) pname version sha256;
      };

      doCheck = false;
    }
  ) requirements;

  # Sett sammen alle pakkene i én Python-closure
  pythonEnv = python3.withPackages (_: builtPackages);

in {
  o3dePython = pythonEnv;
}

