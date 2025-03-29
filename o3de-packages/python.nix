{ pkgs, python, pyproject-nix }:

let
  project = pyproject-nix.lib.project.loadRequirementsTxt {
    requirements = builtins.readFile ./requirements.txt;
  };
in
  python.withPackages (project.renderers.withPackages { inherit python; })

