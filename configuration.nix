{ config, pkgs, lib, ... }:
{
  # NixOS wants to enable GRUB by default
  boot.loader.grub.enable = false;
  # Enables the generation of /boot/extlinux/extlinux.conf
  boot.loader.generic-extlinux-compatible.enable = true;
 
  # !!! Set to specific linux kernel version
  boot.kernelPackages = pkgs.linuxPackages_5_4;

  # !!! Needed for the virtual console to work on the RPi 3, as the default of 16M doesn't seem to be enough.
  # If X.org behaves weirdly (I only saw the cursor) then try increasing this to 256M.
  # On a Raspberry Pi 4 with 4 GB, you should either disable this parameter or increase to at least 64M if you want the USB ports to work.
  boot.kernelParams = ["cma=256M"];
    
  # File systems configuration for using the installer's partition layout
  fileSystems = {
    # Prior to 19.09, the boot partition was hosted on the smaller first partition
    # Starting with 19.09, the /boot folder is on the main bigger partition.
    # The following is to be used only with older images.
    /*
    "/boot" = {
      device = "/dev/disk/by-label/NIXOS_BOOT";
      fsType = "vfat";
    };
    */
    "/" = {
      device = "/dev/disk/by-label/NIXOS_SD";
      fsType = "ext4";
    };
  };

  # !!! Adding a swap file is optional, but strongly recommended!
  swapDevices = [ { device = "/swapfile"; size = 1024; } ];

  # systemPackages
  environment.systemPackages = with pkgs; [ 
    vim curl wget nano bind helm iptables python3 nodejs-12_x
  ];

  services.openssh = {
      enable = true;
      permitRootLogin = "yes";
  };

  # Some sample service.
  # Use dnsmasq as internal LAN DNS resolver.
  /* services.dnsmasq = { */
  /*     enable = false; */
  /*     servers = [ "8.8.8.8" "8.8.4.4" "1.1.1.1" ]; */
  /*     extraConfig = '' */
  /*       address=/fenrir.test/192.168.100.6 */
  /*       address=/recalune.test/192.168.100.7 */
  /*       address=/eth.nixpi.test/192.168.100.3 */
  /*       address=/wlan.nixpi.test/192.168.100.4 */
  /*     ''; */
  /* }; */

  # services.openvpn = {
  #     # You can set openvpn connection
  #     servers = {
  #       privateVPN = {
  #         config = "config /home/nixos/vpn/privatvpn.conf";
  #       };
  #     };
  # };

  programs.zsh = {
      enable = true;
      /* ohMyZsh = { */
      /*     enable = true; */
      /*     theme = "bira"; */
      /* }; */
  };


  virtualisation.docker.enable = true;

  networking.firewall.enable = false;
  

  # WiFi
  hardware = {
    enableRedistributableFirmware = true;
    firmware = [ pkgs.wireless-regdb ];
  };
  # Networking
  networking = {
    # useDHCP = true;
    interfaces.wlan0 = {
      useDHCP = false;
      ipv4.addresses = [{
        # I used static IP over WLAN because I want to use it as local DNS resolver
        address = "192.168.100.110";
        prefixLength = 24;
      }];
    };
    interfaces.eth0 = {
      useDHCP = true;
      # I used DHCP because sometimes I disconnect the LAN cable
      #ipv4.addresses = [{
      #  address = "192.168.100.3";
      #  prefixLength = 24;
      #}];
    };

    # Enabling WIFI
    /* wireless.enable = true; */
    /* wireless.interfaces = [ "wlan0" ]; */
    /* # If you want to connect also via WIFI to your router */
    /* wireless.networks."WIFI-SSID".psk = "wifipass"; */
    /* # You can set default nameservers */
    /* nameservers = [ "8.8.8.8" "8.8.4.4" ]; */
    /* # You can set default gateway */
    /* defaultGateway = { */
    /*   address = "192.168.100.1"; */
    /*   interface = "wlan0"; */
    /* }; */
  };

  # put your own configuration here, for example ssh keys:
  users.defaultUserShell = pkgs.zsh;
  users.mutableUsers = true;
  users.groups = {
    nixos = {
      gid = 1000;
      name = "nixos";
    };
  };
  users.users = {
    nixos = {
      uid = 1000;
      home = "/home/nixos";
      name = "nixos";
      group = "nixos";
      shell = pkgs.zsh;
      extraGroups = [ "wheel" "docker" ];
    };
  };
  users.extraUsers.root.openssh.authorizedKeys.keys = [
    # This is my public key
     "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDtDNBQCp2rwfY87likruDHMvSms73D6+sZLEo6VcdX8+uabQMQN6fxsdX8DLLflaDqphsLv8kqYnfgoxB5qv+fjlPxGEuVlhrXKXqdLPJbdE5o/p3WM4VGLbFw/pfn50RzixKabwDLaJipkqm5Y78N0L9DkhafheUvWxsNJZYPRaPpEGqJfValM89bKWQbWS/siIXPiB1EYoM4PLxuVFpqm7BL7G/Y8pMRMFcj+IfHx+8WN0pCDtYowvcp9Ay8Qy1m1uSJ+TfapMnhCWeJlM3uPP+/F7Lv8fRhNRYtS2RrCq/W6/dsdLFjeTYtxgPD+wqxpLlBjiAy3NCxFsYZFGIR tau@tau"
  ];
}
