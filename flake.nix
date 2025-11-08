
{
  inputs = {
    nixpkgs.url = github:NixOS/nixpkgs/nixos-unstable;
    home-manager.url = github:nix-community/home-manager;
    hyprsession.url = github:joshurtree/hyprsession;
    flake-utils.url = github:numtide/flake-utils;

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
      # Function to create a NixOS configuration for a host
      mkHost = hostName: 
        let
          # Import host-specific inputs if the file exists, otherwise use all inputs
          hostSpecificInputs = 
            if builtins.pathExists (./hosts + "/${hostName}/inputs.nix")
            then import (./hosts + "/${hostName}/inputs.nix") { inherit inputs; }
            else inputs;
        in
        nixpkgs.lib.nixosSystem {
          system = import ./hosts/${hostName}/system.nix;
          specialArgs = { inputs = hostSpecificInputs; };
          modules = [ 
            ./hosts/${hostName}/configuration.nix
            ./hosts/${hostName}/hardware-configuration.nix
            ./common/configuration.nix
            { networking.hostName = hostName; }
          ];
        };

      # Get all host directories that contain a configuration.nix file
      hostDirs = builtins.filter 
        (name: builtins.pathExists (./hosts + "/${name}/configuration.nix"))
        (builtins.attrNames (builtins.readDir ./hosts));

      # Create nixosConfigurations for each valid host
      hostConfigurations = builtins.listToAttrs (
        map (hostName: {
          name = hostName;
          value = mkHost hostName;
        }) hostDirs
      );
    in
    {
      nixosConfigurations = hostConfigurations;
    };
}
