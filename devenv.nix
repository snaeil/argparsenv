{
  pkgs,
  lib,
  config,
  inputs,
  ...
}:

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

  scripts = {
    formatter = {
      exec = "poetry run black .";
      description = "Format code with Black";
    };
    typecheck = {
      exec = "poetry run mypy --ignore-missing-imports argparsenv";
      description = "Type check with Mypy";
    };
    unit-tests = {
      exec = "ulimit -n 50000 && poetry run pytest -v";
      description = "Run unit tests";
    };
    doc-tests = {
      exec = "ulimit -n 50000 && poetry run pytest --doctest-modules";
      description = "Run doctests";
    };
    lint = {
      exec = "pylint --rcfile=.pylintrc argparsenv && poetry run pylint --rcfile=.pylintrc.tests tests/**/*.py";
      description = "Lint source code";
    };
    test-coverage = {
      exec = "ulimit -n 50000 && poetry run pytest --cov-report html --cov=. argparsenv";
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
    black = {
      enable = true;
      name = "Black";
      entry = "formatter";
      types = [ "python" ];
      language = "system";
      pass_filenames = true;
    };
    commitizen = {
      enable = true;
    };
  };
}
