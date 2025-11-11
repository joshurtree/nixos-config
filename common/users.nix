{ config, pkgs, nixpkgs, ...}:

{
  users.users.josh = {
    isNormalUser = true;
    description = "Josh Andrews";
    extraGroups = [ "networkmanager" "wheel" "docker" "dialout" "qemu" "libvirt" ];
    #hashedPassword = nixpkgs.lib.mkPasswordFile ../secrets/josh-password;
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCnpszwUxL/X0TBwZDppm4Gf9geh+zznyN//EHfnrJu7f2s580RUhECHCYHqov8yVLnjwAdelzbW7G7mI6I8qcdR/b6ITTxhlbgfMzqLbJuZCIS7jn4xMtKAGvybhVouxuGkcMWr65b280S76EfVuqeXfTqJekH7pDBUzdd9zGPkrqO7SkMiVFpZLJE+nsmYkGHBcEAlxgMvKkM4Ku7oEPR/44DfwtG+0XLn8IW6hu8tol9E3qUOvX66/BsVEABVaNwoZ3R9M1bZvCNUb/puAHo/dxz0173ZppgnT0ydkj1EAbECqhNs/RlrIQsJ18FTH3zhyOZQSNKnIsbN3zfAJVyshCI0pW4aZ1Rj/PfoIs6BVNhdGvkdHHRe/D0LTT9+cqof/Wh2TvgLx1Ur9/5QMIjtVmkc8BtbUf2lJRRZEDur8n0a+ms2TCBidawKT/UTqxETm17rqQXlj4oQk9OAvrGeu92b0GRoReYaFz0wBzrG4cemobAhMhtoptZRNSwz6U= josh@acer-laptop"
    ];
  };
}
