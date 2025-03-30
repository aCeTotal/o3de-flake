{ pkgs, python, pyproject-nix, fork, ... }:

let
  # Parse requirements.txt via pyproject-nix
  project = pyproject-nix.lib.project.loadRequirementsTxt {
    requirements = builtins.readFile ./requirements.txt;
  };

  # Bygg o3de-modulen fra gitt kildekode (`fork`) via flake
  o3dePythonLib = python.pkgs.buildPythonPackage {
    pname = "o3de";
    version = "1.0.0";  # Må matche setup.py i /scripts/o3de
    format = "setuptools";
    src = "${fork}/scripts/o3de";

    doCheck = false;

    propagatedBuildInputs = [ ];

    meta = {
      description = "O3DE editor Python bindings test tools";
      homepage = "https://github.com/o3de/o3de";
      license = pkgs.lib.licenses.asl20;
    };
  };

in
  # Kombinerer alle dependencies og o3de-modulen i ett python-miljø
  python.withPackages (ps:
    (project.renderers.withPackages { inherit python; })(ps)
    ++ [ o3dePythonLib ]
  )

