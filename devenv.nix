{
  pkgs,
  lib,
  config,
  inputs,
  ...
}:
let
  source_dir_name = "argparsenv";
in
{
  # https://devenv.sh/packages/
  packages = [ pkgs.git ];

  # https://devenv.sh/languages/
  languages.python = {
    enable = true;
    version = "3.11";
    poetry = {
      enable = true;
      activate.enable = true;
      install = {
        enable = true;
        installRootPackage = false;
      };
    };
  };

  # Sourcing is needed for pre-commit to use the correct python venv
  scripts = {
    formatter = {
      exec = "source .venv/bin/activate && poetry run black .";
      description = "Format the code, using black";
    };
    typecheck = {
      exec = "source .venv/bin/activate && poetry run mypy --ignore-missing-imports ${source_dir_name}";
      description = "Type check with Mypy";
    };
    unit-tests = {
      exec = "source .venv/bin/activate && ulimit -n 50000 && poetry run pytest -v";
      description = "Run unit tests";
    };
    doc-tests = {
      exec = "source .venv/bin/activate && ulimit -n 50000 && poetry run pytest --doctest-modules";
      description = "Run doctests";
    };
    lint = {
      exec = "source .venv/bin/activate && poetry run pylint --rcfile=.pylintrc ${source_dir_name}";
      description = "Lint source code";
    };
    test-coverage = {
      exec = "source .venv/bin/activate && ulimit -n 50000 && poetry run pytest --cov-report html --cov=. ${source_dir_name}";
      description = "Generate coverage report";
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
