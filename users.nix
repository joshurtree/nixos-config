{ config, pkgs, ...}:

{
  users.users.josh = {
    isNormalUser = true;
    description = "Josh Andrews";
    extraGroups = [ "networkmanager" "wheel" "docker" ];
    packages = with pkgs; [
      kdePackages.kate
      thunderbird
      vscode-fhs
      discord
      kitty
      bitwarden-desktop
      bitwarden-cli
      bitwarden-menu
      waybar  
      openttd
      hypridle        
    ];
    initialPassword = "123";
  };
}
