{
  description = "Nix configuration for MacOS";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nix-homebrew = {
      url = "github:zhaofengli/nix-homebrew";
      inputs.brew-src.url = "github:Homebrew/brew";
    };

    # Prebuilt nix-index database, so command-not-found and comma work
    # without an expensive local indexing run.
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    llm-agents.url = "github:numtide/llm-agents.nix";

    nixvim.url = "github:nix-community/nixvim/main";

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Private repo holding the SSZSPL-licensed Comic Code OTFs; fetched over
    # SSH and pinned by rev, same arrangement as the secrets input below.
    # ssh.github.com:443 is just GitHub's SSH-over-443 endpoint; it exists so
    # this and the secrets input use different hostnames, letting CI pin one
    # deploy key per host (SSH cannot pick between two keys for one host).
    comic-code = {
      url = "git+ssh://git@ssh.github.com:443/munza/comic-code.git";
      flake = false;
    };

    # Private repo; ciphertext deliberately kept out of this public one.
    # Managed with `nix-secret`, which keeps a working checkout separately.
    secrets = {
      url = "git+ssh://git@github.com/munza/nix-secret.git";
      flake = false;
    };

    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    blueprint.url = "github:numtide/blueprint";
    blueprint.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    inputs:
    let
      systems = [
        "aarch64-darwin"
        "aarch64-linux"
        "x86_64-linux"
      ];
      inherit (inputs.nixpkgs) lib;
      blueprintOutputs = inputs.blueprint { inherit inputs systems; };
      forEachSystem = f: lib.genAttrs systems (system: f inputs.nixpkgs.legacyPackages.${system});
      treefmtEval = forEachSystem (pkgs: inputs.treefmt-nix.lib.evalModule pkgs ./treefmt.nix);

      # Blueprint exports modules that take no publisher args (pkgs, var,
      # hostPackages, ...) as their file location instead of a module value —
      # a path when the source is a path, a store-path string when it comes
      # from self.outPath. The module system happily imports either, but
      # newer Nix's `flake check` requires every *Modules.<name> to be a
      # function or attrset, so normalise them to imported functions.
      asFunctions =
        attrs: lib.mapAttrs (_: m: if builtins.isPath m || builtins.isString m then import m else m) attrs;
    in
    blueprintOutputs
    // {
      homeModules = asFunctions blueprintOutputs.homeModules;
      darwinModules = asFunctions blueprintOutputs.darwinModules;
      nixosModules = asFunctions blueprintOutputs.nixosModules;

      formatter = forEachSystem (pkgs: treefmtEval.${pkgs.system}.config.build.wrapper);
      checks = lib.recursiveUpdate blueprintOutputs.checks (
        forEachSystem (pkgs: {
          formatting = treefmtEval.${pkgs.system}.config.build.check inputs.self;
        })
      );
    };
}
