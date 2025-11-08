{ config, pkgs, ... }:

{
  # Enable container runtime support
  virtualisation = {
    containers.enable = true;

    podman = {
      # dockerCompat = true;  # Uncomment to enable Docker compatibility
      defaultNetwork.settings.dns_enabled = true;
    };

    docker = {
      enable = true;
    };
  };

  # Container-related packages
  environment.systemPackages = with pkgs; [
    dive # look into docker image layers
    podman-tui # status of containers in the terminal
    docker-compose # start group of containers for dev
    podman-compose # start group of containers for dev
  ];

  # Add users to docker group
  users.users.josh = {
    extraGroups = [ "docker" ];
  };
}
