{
  inputs.nix-flake-tests.url = github:antifuchs/nix-flake-tests;
  inputs.nix-log.inputs.nix-flake-tests.follows = "nix-flake-tests";
  inputs.nix-log.inputs.nixify.follows = "nixify";
  inputs.nix-log.inputs.nixlib.follows = "nixlib";
  inputs.nix-log.url = github:rvolosatovs/nix-log/v0.1.5;
  inputs.nixify.inputs.nixpkgs.follows = "nixpkgs";
  inputs.nixify.url = github:rvolosatovs/nixify;
  inputs.nixlib.url = github:nix-community/nixpkgs.lib;
  inputs.nixpkgs.url = github:NixOS/nixpkgs/nixpkgs-23.05-darwin;

  outputs = {nixify, ...} @ inputs:
    nixify.lib.mkFlake {
      withChecks = {
        checks,
        pkgs,
        ...
      }:
        checks // import ./checks inputs pkgs;
    }
    // {
      lib = import ./lib inputs;
    };
}
