# configuration.nix

{ config, pkgs, lib, inputs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
      ./impermanence.nix
      ./users.nix
      ./myparams.nix
      ./desktop.nix
      (import ./disko-config.nix {
        disks = [ "/dev/vda" ]; 
      })
    ];

  # Desktop
  myDesktop = "pantheon";
  # myDesktop = "kde";
  # This is the initial desktop as defined by install script
  # myDesktop = config.myParams.mydesktop;

  
  ### Nix options
  ###############
  # Re-use nixpkgs from flake for nix commands
  nix.registry.nixpkgs.flake = inputs.nixpkgs;
  # Allow unfree packages
  nixpkgs.config = {
    allowUnfree = true;
  };
  # Enable flakes & new syntax
  nix = {
    extraOptions = ''
      experimental-features = nix-command
      extra-experimental-features = flakes
    '';
  };


  # Boot loader
  boot.loader = {
    efi.canTouchEfiVariables=true;
    # systemd-boot.enable = true;
    grub = { 
        enable = true;
        devices = [ "nodev" ];
        efiSupport = true;
    };
    timeout = 3;
  };


  ####################
  ##  Localization  ##
  ####################
  time.timeZone = "Europe/London";
  # Internationalisation
  i18n.defaultLocale = "en_GB.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "uk";
  };


  ################
  ##  Network  ###
  ################
  networking.hostName = config.myParams.myhostname;
  networking.networkmanager.enable = true;

  # Open ports in firewall.
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 22 ];
    allowedUDPPorts = [ ];
  };



  #############
  ## Kernel ###
  #############
  # Custom Kernels
  # boot.kernelPackages = pkgs.linuxPackages_zen;
  # boot.kernelPackages = pkgs.linuxPackages_latest;
  # boot.kernelPackages = pkgs.linuxPackages_hardened;


  ################
  ### Drivers ####
  ################
  
  services.xserver.videoDrivers = [ "amdgpu" "radeon" "modesetting" "fbdev" ];
  # boot.initrd.kernelModules = [ "radeon" ];
  boot.kernelParams = [
    "video=HDMI-A-1:1920x1200@60"
    "video=VIRTUAL-1:1920x1092@60"
  ];
  # services.xserver.displayManager.setupCommands = '' 
  # xrandr --mode 1920x1092 --rate 60 
  # '';
  ### OpenGL ###
  # hardware.opengl = {
  #   enable = true;
  #   driSupport = true;
  #   driSupport32Bit = true;
  #   extraPackages = [ pkgs.libGL pkgs.libGLU ];
  # };

  ### Spice ###
  systemd.user.services.spice-agent = {
    enable = true;
    wantedBy = ["graphical-session.target"]; 
    serviceConfig = { ExecStart = "${pkgs.spice-vdagent}/bin/spice-vdagent -x"; }; 
    unitConfig = { ConditionVirtualization = "vm"; 
      Description = "Spice guest session agent";
      After = ["graphical-session-pre.target"];
      PartOf = ["graphical-session.target"]; 
    }; 
  }; 

  services.spice-vdagentd.enable = true;

  # Needed for gpu passthrough as guest
  # https://old.reddit.com/r/NixOS/comments/14cjbnr/gpu_passthrough_wont_work_in_nixos_guest/
  hardware.enableRedistributableFirmware = lib.mkDefault true;


  ################
  ### Security ###
  ################

  services.packagekit.enable = true;
  services.fwupd.enable = true;

  # Enable Apparmor
  security.apparmor.enable = true;

  # Enable doas. Turn off sudo.
  security.doas.enable = true;
  security.sudo.enable = true;

  security.sudo.extraConfig = ''
    # rollback results in sudo lectures after each reboot
    Defaults lecture = never
  '';


  ################
  ### Clean-Up ###
  ################

  # Mount /tmp as tmpfs
  boot.tmp.useTmpfs = true;
  
  # Clean-out /var/tmp for files older than 7 days. 
  # Is this still needed?
  # systemd.tmpfiles.rules = [ "q /var/tmp 1777 root root 7d" ];
  # systemd.tmpfiles.rules = [ "d /var/tmp 1777 root root 7d" ];

  # https://nixos.wiki/wiki/Storage_optimization
  nix.settings.auto-optimise-store = true;
  # Garbage Collection 
  nix.gc = {
    automatic = true;
    dates = "daily";
    options = "--delete-older-than 3d";
  };



  ################
  ### Programs ###
  ################

  # Set default editor
  environment.variables.EDITOR = "hx";

  # Shell
  # programs.zsh.enable = true;
  programs.fish = {
    enable = true;
    # interactiveShellInit = ''
    #   set fish_greeting "Welcome to fish shell!"
    # '';
    };

  # System Packages
  environment.systemPackages = with import ./packages.nix {inherit pkgs config; }; my-package-set;

  # Nerd fonts 
  fonts.fonts = with pkgs; [
    (nerdfonts.override { fonts = [ "FiraCode" "DroidSansMono" "Hack" ]; })
  ];

  # Firejailed apps
  # programs.firejail = {
  #   enable = true;
  #   wrappedBinaries = 
  #   {     
  #     # librewolf
  #     jailwolf = {
  #       executable = "${lib.getBin pkgs.librewolf}/bin/librewolf";
  #       profile = "${pkgs.firejail}/etc/firejail/librewolf.profile";
  #       extraArgs = [ "--private=~/sandbox" ];
  #     };
  #     # firefox
  #     jailfox = {
  #       executable = "${lib.getBin pkgs.firefox}/bin/firefox --no-remote";
  #       profile = "${pkgs.firejail}/etc/firejail/firefox.profile";
  #       extraArgs = [ "--private=~/sandbox" ];
  #     };
  #   };
  # };



  ############
  # Services #
  ############
 
  ### Sound ###
  ## https://nixos.wiki/wiki/PipeWire
  ## rtkit is optional but recommended
  # security.rtkit.enable = true;
  # services.pipewire = {
  #   enable = true;
  #   alsa.enable = true;
  #   alsa.support32Bit = true;
  #   pulse.enable = true;
  # ## Uncomment to use JACK applications:
  # # jack.enable = true;
  # };

  ### Flatpak ###
  services.flatpak.enable = true;
  # Daily updates wit systemd
  systemd.services.flatpak-update = {
    serviceConfig.Type = "oneshot";
    path = [ pkgs.flatpak ];
    serviceConfig.ExecStart = "${pkgs.flatpak}/bin/flatpak update -y";
  };
  systemd.timers.flatpak-update = {
    wantedBy = [ "timers.target" ];
    partOf = [ "flatpak-update.service" ];
    timerConfig = {
      OnCalendar = "*-*-* 15:20:00";
      Unit = "flatpak-update.service";
    };
  };
  # XDG portals for sandboxed apps
  xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];


  ### Podman ###
  virtualisation = {
    podman = {
      enable = true;
      # docker alias for podman
      dockerCompat = true;
    };
  };

  # virtualisation.podman = {
  #   enable = true;
  #   dockerCompat = true;
  #   defaultNetwork.settings = { dns_enabled = true; };
  # };
  # security.unprivilegedUsernsClone = true;

  # virtualisation = {
  #   lxd.enable = true;
  # };


  ### SSH ###
  services.openssh = {
   enable = true;
   # passwordAuthentication = false;
   settings.PasswordAuthentication = false;
   allowSFTP = false; # Don't set this if you need sftp
   settings.KbdInteractiveAuthentication = false;
   extraConfig = ''
     AllowTcpForwarding yes
     X11Forwarding no
     AllowAgentForwarding no
     AllowStreamLocalForwarding no
     AuthenticationMethods publickey
   '';
  };


  # Read the doc before updating
  system.stateVersion = "23.05";

}

