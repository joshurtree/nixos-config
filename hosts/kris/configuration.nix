{ config, pkgs, nixpkgs, inputs, ... }:

{
  networking = {
    hostName = "kris";
    networkmanager.enable = true;
    
    # Static IP configuration
    interfaces.eth0.ipv4.addresses = [ {
      address = "192.168.2.252";
      prefixLength = 24;
    } ];

    # wireless.enable = true;
    # interfaces.wlan0.ipv4.addresses = [ {
    #   address = "192.168.2.251";
    #   prefixLength = 24;  
    # } ];
    defaultGateway = "192.168.2.1";
    
    firewall.interfaces.eth0 = {
      allowedTCPPorts = [ 5335 8080 3001];
      allowedUDPPorts = [ 5335 ];
    };
  };

  services = {
    uptime-kuma.enable = true;
    pihole = { 
      enable = true;
      hostConfig = {
        # define the service user for running the rootless Pi-hole container
        user = "pihole";
        enableLingeringForUser = true;

        # we want to persist change to the Pi-hole configuration & logs across service restarts
        # check the option descriptions for more information
        persistVolumes = true;

        # expose DNS & the web interface on unpriviledged ports on all IP addresses of the host
        # check the option descriptions for more information
        dnsPort = 5335;
        webProt = 8080;
      };
      piholeConfig.ftl = {
        # assuming that the host has this (fixed) IP and should resolve "pi.hole" to this address
        # check the option description & the FTLDNS documentation for more information
        LOCAL_IPV4 = "192.168.2.252";
      };
      piholeConfig.web = {
        virtualHost = "pihole2";
        password = builtins.readFile ../../secrets/pihole-password;
      };
    };
  };
}