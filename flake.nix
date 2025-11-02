{
  inputs = {
    nixpkgs.url = github:NixOS/nixpkgs/nixos-unstable;
    home-manager.url = github:nix-community/home-manager;
    hyprsession.url = github:joshurtree/hyprsession;
  };

  outputs = { self, nixpkgs, ... }@attrs: {
    nixosConfigurations.dave = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = attrs;
      modules = [ ./configuration.nix ];
    };
  };
}
