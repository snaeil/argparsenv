{
  pkgs,
  lib,
  config,
  inputs,
  ...
}:
let
  source_dir_name = "argparsenv";
  venv = ".devenv/state/venv/bin";
in
{
  # https://devenv.sh/packages/
  packages = [ pkgs.git ];

  # https://devenv.sh/languages/
  languages.python = {
    enable = true;
    version = "3.11";
    venv.enable = true;
    uv = {
      enable = true;
      sync.enable = true;
      sync.allGroups = true;
    };
  };

  # Sourcing is needed for pre-commit to use the correct python venv
  scripts = {
    formatter = {
      exec = "source ${venv}/activate && uv run black .";
      description = "Format the code, using black";
    };
    typecheck = {
      exec = "source ${venv}/activate && uv run mypy --ignore-missing-imports ${source_dir_name}";
      description = "Type check with Mypy";
    };
    unit-tests = {
      exec = "source ${venv}/activate && ulimit -n 50000 && uv run pytest -v";
      description = "Run unit tests";
    };
    doc-tests = {
      exec = "source ${venv}/activate && ulimit -n 50000 && uv run pytest --doctest-modules";
      description = "Run doctests";
    };
    lint = {
      exec = "source ${venv}/activate && uv run pylint --rcfile=.pylintrc ${source_dir_name}";
      description = "Lint source code";
    };
    test-coverage = {
      exec = "source ${venv}/activate && ulimit -n 50000 && uv run pytest --cov-report html --cov=. ${source_dir_name}";
      description = "Generate coverage report";
    };
    security-check = {
      exec = "uv audit";
      description = "Check for vulnerabilities";
    };
  };

  enterShell = ''
    echo
    echo "Helper scripts/tools you can run and that are (mostly) used by pre-commit:"
    echo
    ${pkgs.gnused}/bin/sed -e 's| |••|g' -e 's|=| |' <<EOF | ${pkgs.util-linuxMinimal}/bin/column -t | ${pkgs.gnused}/bin/sed -e 's|^|🦾 |' -e 's|••| |g'
    ${lib.generators.toKeyValue { } (lib.mapAttrs (name: value: value.description) config.scripts)}
    EOF
    echo
  '';

  # https://devenv.sh/pre-commit-hooks/
  git-hooks.hooks = {
    commitizen = {
      enable = true;
    };
    formatter = {
      enable = true;
      name = "Black";
      entry = "formatter";
      types = [ "python" ];
      language = "system";
      pass_filenames = true;
    };
    unit-tests = {
      enable = true;
      name = "Unit tests";
      entry = "unit-tests";
      types = [
        "python"
        "toml"
      ];
      language = "system";
      pass_filenames = false;
      always_run = true;
    };
    doc-tests = {
      enable = true;
      name = "Doctests";
      entry = "doc-tests";
      types = [
        "python"
        "toml"
      ];
      language = "system";
      pass_filenames = true;
    };
    lint = {
      enable = true;
      name = "Lint source code";
      entry = "lint";
      types = [
        "python"
        "toml"
      ];
      language = "system";
      pass_filenames = false;
      always_run = true;
    };
    security-check = {
      enable = true;
      name = "Check for vulnerabilities";
      entry = "security-check";
      language = "system";
      pass_filenames = false;
      always_run = true;
    };
    typecheck = {
      enable = true;
      name = "Mypy";
      entry = "typecheck";
      types = [
        "python"
        "toml"
      ];
      language = "system";
      pass_filenames = false;
    };
  };
}
