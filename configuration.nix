# configuration.nix

{ config, pkgs, lib, inputs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
      ./impermanence.nix
      ./users.nix
      ./myparams.nix
      (import ./disko-config.nix {
        disks = [ "/dev/nvme0n1" ]; 
      })
    ];

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
  #  efi.canTouchEfiVariables=true;
    systemd-boot.enable = true;
  };


  ####################
  ##  Localization  ##
  ####################
  time.timeZone = "UTC";
  # Internationalisation
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
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
  boot.kernelPackages = pkgs.linuxPackages_hardened;

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
  environment.variables.EDITOR = "nvim";

  # Shell
  programs.zsh.enable = true;

  # System Packages
  environment.systemPackages = with import ./packages.nix {inherit pkgs config; }; my-package-set;

  # Nerd fonts 
  fonts.fonts = with pkgs; [
    (nerdfonts.override { fonts = [ "FiraCode" "DroidSansMono" "Hack" ]; })
  ];

    ############
  # Services #
  ############
 
    ### Podman ###
  virtualisation = {
    lxd.enable = true;
    podman = {
      enable = true;
      # docker alias for podman
      dockerCompat = true;
    };
  };

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

