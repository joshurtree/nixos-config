
{
  inputs = {
      nixpkgs.url = github:NixOS/nixpkgs/nixos-unstable;
      flake-utils.url = github:numtide/flake-utils;

      # Used for dave
      hyprsession.url = github:joshurtree/hyprsession;
      home-manager.url = github:nix-community/home-manager;

      # Used for kris
      linger = {
        url = "github:mindsbackyard/linger-flake";
        inputs.flake-utils.follows = "flake-utils";
        };

      pihole = {
        url = "github:mindsbackyard/pihole-flake";
        inputs.nixpkgs.follows = "nixpkgs";
        inputs.flake-utils.follows = "flake-utils";
        inputs.linger.follows = "linger";
      };

  };

  outputs = { self, nixpkgs, ... }@inputs: 
    let
      hosts = builtins.attrNames(builtins.readDir(./hosts));
    in {
      # Create nixosConfigurations for each valid host
      nixosConfigurations = builtins.listToAttrs (
        map (hostName: {
          name = hostName;
          value = nixpkgs.lib.nixosSystem {
            system = import ./hosts/${hostName}/system.nix;
            specialArgs = { inherit inputs; };
            modules = [ 
              ./hosts/${hostName}/configuration.nix
              ./hosts/${hostName}/hardware-configuration.nix
              ./common/configuration.nix
              { networking.hostName = hostName; }
            ];
          };
        }) hosts
      );
    };
}
