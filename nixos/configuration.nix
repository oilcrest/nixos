# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:

let
  impermanence = builtins.fetchTarball "https://github.com/nix-community/impermanence/archive/master.tar.gz";
  packageGroups = import ./packages.nix { inherit pkgs; };
in
{
  imports =
    [
      "${impermanence}/nixos.nix"
      ./hardware-configuration.nix
      ./users.nix
    ];

  # filesystems
  fileSystems."/".options = ["compress=zstd" "noatime" ];
  fileSystems."/home".options = ["compress=zstd" "noatime" ];
  fileSystems."/nix".options = ["compress=zstd" "noatime" ];
  fileSystems."/persist".options = ["compress=zstd" "noatime" ];
  fileSystems."/var/log".options = ["compress=zstd" "noatime" ];

  fileSystems."/persist".neededForBoot = true;
  fileSystems."/var/log".neededForBoot = true;

  # reset / at each boot
  # Note `lib.mkBefore` is used instead of `lib.mkAfter` here.
  boot.initrd.postDeviceCommands = pkgs.lib.mkBefore ''
    mkdir -p /mnt

    # We first mount the btrfs root to /mnt
    # so we can manipulate btrfs subvolumes.
    mount -o subvol=/ /dev/vda3 /mnt

    # While we're tempted to just delete /root and create
    # a new snapshot from /root-blank, /root is already
    # populated at this point with a number of subvolumes,
    # which makes `btrfs subvolume delete` fail.
    # So, we remove them first.
    #
    # /root contains subvolumes:
    # - /root/var/lib/portables
    # - /root/var/lib/machines
    #
    # I suspect these are related to systemd-nspawn, but
    # since I don't use it I'm not 100% sure.
    # Anyhow, deleting these subvolumes hasn't resulted
    # in any issues so far, except for fairly
    # benign-looking errors from systemd-tmpfiles.
    btrfs subvolume list -o /mnt/root |
    cut -f9 -d' ' |
    while read subvolume; do
      echo "deleting /$subvolume subvolume..."
      btrfs subvolume delete "/mnt/$subvolume"
    done &&
    echo "deleting /root subvolume..." &&
    btrfs subvolume delete /mnt/root

    echo "restoring blank /root subvolume..."
    btrfs subvolume snapshot /mnt/root-blank /mnt/root

    # Once we're done rolling back to a blank snapshot,
    # we can unmount /mnt and continue on the boot process.
    umount /mnt
  '';

  # configure impermanence
  environment.persistence."/persist" = {
    directories = [
      "/etc/nixos"
    ];
    files = [
      "/etc/machine-id"
      #"/etc/ssh/ssh_host_ed25519_key"
      #"/etc/ssh/ssh_host_ed25519_key.pub"
      #"/etc/ssh/ssh_host_rsa_key"
      #"/etc/ssh/ssh_host_rsa_key.pub"
    ];
  };

  nixpkgs.config = {
    allowUnfree = true;
    # packageOverrides = pkgs: {
    #  unstable = import <nixos-unstable> {
    #    config = config.nixpkgs.config;
    #  };
    # };
  };

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


  # https://nixos.wiki/wiki/Storage_optimization
  # nix.autoOptimiseStore = true;
  nix.settings.auto-optimise-store = true;
  # Garbage Collection 
  nix.gc = {
    automatic = true;
    dates = "daily";
    options = "--delete-older-than 3d";
  };

  nix = {
    extraOptions = ''
      experimental-features = nix-command
      extra-experimental-features = flakes
    '';
  };

  security.sudo.extraConfig = ''
    # rollback results in sudo lectures after each reboot
    Defaults lecture = never
  '';

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
  networking.hostName = "nixos";
  networking.networkmanager.enable = true;

  # Open ports in the firewall.
  # networking.firewall = {
  #   enable = true;
  #   allowedTCPPorts = [ 22 ];
  #   allowedUDPPorts = [ ];
  # };


  #############
  ## Desktop ##
  #############

  # Enable X11, sddm and KDE plasma.
  services.xserver = {
	enable=true;
  	displayManager.sddm.enable = true;
  	desktopManager.plasma5.enable = true;
	#displayManager.setupCommands = "xrandr -display :0.0 --output Virtual-1 --mode 1920x1080";
    # X11 keymap
    layout = "gb";
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

  ### OpenGL ###
  # hardware.opengl = {
  #   enable = true;
  #   driSupport = true;
  #   driSupport32Bit = true;
  #   extraPackages = [ pkgs.libGL pkgs.libGLU ];
  # };


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

  # Mount /tmp as tmpfs
  boot.tmpOnTmpfs = true;
  
  # Clean-out /var/tmp for files older than 7 days. 
  # systemd.tmpfiles.rules = [ "q /var/tmp 1777 root root 7d" ];
  # systemd.tmpfiles.rules = [ "d /var/tmp 1777 root root 7d" ];



  ################
  ### Programs ###
  ################

  programs.neovim = {
    enable = true;
    # package = unstable.neovim;
    viAlias = true;
    vimAlias = true;
  };

  programs.zsh.enable = true;
  # environment.shellAliases = {
  #   vim = "nvim";
  # };

  # programs.chromium = {
  #   enable = true;
  #   homepageLocation = "https://nixos.org"; 
  #   extensions =
  #   [
  #   "gcbommkclmclpchllfjekcdonpmejbdp" # https everywhere
  #   "cjpalhdlnbpafiamejdnhcphjbkeiagm" # ublock origin
  #   ];	
  # };

  
  # System Packages to install
  environment.systemPackages = with packageGroups; my-package-set;

  # Install specific Nerd fonts 
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
  # https://nixos.wiki/wiki/PipeWire
  # rtkit is optional but recommended
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  # Uncomment to use JACK applications:
  # jack.enable = true;
  };


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
  # XDG portals for sandboxed apps to work:
  xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];

  services.spice-vdagentd.enable = true;

  ### Podman ###
  virtualisation = {
    podman = {
      enable = true;
      # docker alias for podman
      dockerCompat = true;
    };
  };




  system.copySystemConfiguration = true;

  # Read the doc before updating
  system.stateVersion = "22.11";

}

