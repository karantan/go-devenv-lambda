{ pkgs, ... }:

{
  # https://devenv.sh/packages/
  packages = [
    pkgs.git
    pkgs.nodePackages.serverless
  ];

  # https://devenv.sh/languages/
  languages.nix.enable = true;
  languages.go.enable = true;

  # https://devenv.sh/pre-commit-hooks/
  pre-commit = {
    hooks.shellcheck.enable = true;
    # hooks.nixpkgs-fmt.enable = true;
    # hooks.revive.enable = true; # go lint https://github.com/mgechev/revive
    # hooks.govet.enable = true;
    # hooks.gotest.enable = true;
  };

  # https://devenv.sh/scripts/
  # scripts.deploy.exec = "sls deploy";

  enterShell = ''
    echo "---"
    git --version
    go version
    echo "Serverless Framework"
    sls --version
    echo "---"
  '';

  # See full reference at https://devenv.sh/reference/options/
}
