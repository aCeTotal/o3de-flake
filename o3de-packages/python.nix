{ pkgs, python, pyproject-nix }:

let
  # Source with Git LFS
  o3deSrc = pkgs.fetchgit {
    url = "https://github.com/aCeTotal/o3de.git";
    rev = "a16c67a";
    sha256 = "sha256-a16c67a735ea15a17ac1c45e83876255a5567955";
    fetchLFS = true;
  };

  # Parse requirements.txt via pyproject-nix
  project = pyproject-nix.lib.project.loadRequirementsTxt {
    requirements = builtins.readFile ./requirements.txt;
  };

    # Builds the o3de-module from scripts/o3de
    # https://github.com/aCeTotal/o3de/tree/development/scripts/o3de
    # Make sure version matches setup.py
  o3dePythonLib = python.pkgs.buildPythonPackage {
    pname = "o3de";
    version = "1.0.0";
    format = "setuptools";
    src = "${o3deSrc}/scripts/o3de";

    doCheck = false;

    propagatedBuildInputs = [ ];

    meta = {
      description = "O3DE editor Python bindings test tools";
      homepage = "https://github.com/o3de/o3de";
      license = pkgs.lib.licenses.asl20;
    };
  };

in
# Combinds all requirements and the O3DE-module
python.withPackages (ps:
  (project.renderers.withPackages { inherit python; })(ps)
  ++ [ o3dePythonLib ]
)

