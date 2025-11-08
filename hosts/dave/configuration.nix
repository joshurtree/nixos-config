{ config, pkgs, nixpkgs, inputs, ... }:

{
  imports = [ 
      ../../modules/containers.nix
  ];

  boot.kernelParams = [ "intel_iommu=on" ];

  #services.desktopManager.plasma6.enable = true;
  
  services.displayManager = {
    sddm.enable = true;
    sddm.wayland.enable = true;
    autoLogin.enable = true;
    autoLogin.user = "josh";
  };

  programs = {
    hyprland = {
      enable = true;
      xwayland.enable = true;
    };

    partition-manager.enable = true;
    firefox.enable = true;

    mtr.enable = true;
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };
  };

  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-color-emoji
    liberation_ttf
    fira-code
    fira-code-symbols
    mplus-outline-fonts.githubRelease
    dina-font
    proggyfonts
  ] ++ builtins.filter lib.attrsets.isDerivation (builtins.attrValues pkgs.nerd-fonts);

  virtualisation = {
    vmVariant = {
        services.qemuGuest.enable = true;
        virtualisation.sharedDirectories.config = {
          source = "/home/josh";
          securityModel = "none";
          target = "/home/josh";
        };
    };
  };

  security.rtkit.enable = true;

  services = {
    # printing.enable = true;

    pulseaudio.enable = false;
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      # If you want to use JACK applications, uncomment this
      #jack.enable = true;

      # use the example session manager (no others are packaged yet so this is enabled by default,
      # no need to redefine it in your config for now)
      #media-session.enable = true;
    };
  };

  environment.systemPackages = with pkgs; [
    bitwarden-cli
    bitwarden-desktop
    bitwarden-menu
    chromium
    dconf
    discord
    hypridle   
    inputs.hyprsession    
    kdePackages.dolphin 
    kdePackages.kate
    kitty
    libreoffice
    openttd
    rofi
    starship
    thunderbird
    trash-cli         
    vscode-fhs
    waybar
    wl-clipboard
    wlogout
    wofi
    xdg-desktop-portal-hyprland
    xwayland
  ];

  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;
}
