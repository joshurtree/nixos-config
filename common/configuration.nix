{ config, pkgs, nixpkgs, ... }:

{
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  imports = [ ./users.nix ];
  boot = {
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;

    kernelPackages = pkgs.linuxPackages_latest;
    #kernelParams = if config.hostName == "dave" then [ "intel_iommu=on" ] else [ ];
  };

  networking = {
#    wireless = {
#      networks = {
#        "OpenWrt" = {
#          psk = builtins.readFile ../secrets/openwrt;
#        };
#      };
#    };

    networkmanager.enable = true;
  };

  programs.git = {
    enable = true;
    config = {
      user.name = "Josh Andrews";
      user.email = "projects@joshandrews.xyz";
      init.defaultBranch = "main";
    };
  };

  environment.systemPackages = with pkgs; [
    htop
    powertop
    nmap
    curl
    gnumake
    ninja
    polkit
    gh
    jq
    python3
    usbutils
    fastfetch
    cifs-utils
  ];

  time.timeZone = "Europe/London";
  console.keyMap = "uk";

  i18n.defaultLocale = "en_GB.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_GB.UTF-8";
    LC_IDENTIFICATION = "en_GB.UTF-8";
    LC_MEASUREMENT = "en_GB.UTF-8";
    LC_MONETARY = "en_GB.UTF-8";
    LC_NAME = "en_GB.UTF-8";
    LC_NUMERIC = "en_GB.UTF-8";
    LC_PAPER = "en_GB.UTF-8";
    LC_TELEPHONE = "en_GB.UTF-8";
    LC_TIME = "en_GB.UTF-8";
  };

  services = { 
    openssh.enable = true;
    tailscale.enable = true;
  };

  boot.loader.systemd-boot.configurationLimit = 10;
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 1w";
  };

  nix.settings.auto-optimise-store = true;

  nixpkgs.config.allowUnfree = true;
  system.stateVersion = "25.05";
}