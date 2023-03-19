# This is the packages.nix file
{ pkgs, ... }: with pkgs;
#let
#  nix-software-center = (import (pkgs.fetchFromGitHub {
#    owner = "vlinkz";
#    repo = "nix-software-center";
#    rev = "0.1.0";
#    sha256 = "d4LAIaiCU91LAXfgPCWOUr2JBkHj6n0JQ25EqRIBtBM=";
#  })) {};
#in 
rec {

  my-package-set = builtins.concatLists [
      testing
      cli
      utils
      gui
      misc
      kde
    ];


  testing = [
      # nix-software-center
      # ruby
      trickle # network bandwidth limiter
      keyd # Key remapping daemon
      # youtube-dl
      # yt-dlp
      # obsidian
      # brave
      #sl
      #pkg-config
    ];
  
  cli = [
      direnv
      pv # progress viewer
      desktop-file-utils
      gettext
      wget
      git
      unzip
      # appimage-run
      trash-cli
      neofetch
      firejail
      efibootmgr
      zsh
      # distrobox
      xorg.xhost
      #spice-vdagent
      x11spice
    ];
      
  utils = [
      nix-prefetch-docker # Used to get hash info for building docker images with nix
      #unstable.lynis # Security auditing tool
    ];

  gui = [
      gparted
      glxinfo #=glxgears
      filelight 
      firefox
      librewolf
      # ungoogled-chromium
      # logseq
      #signal-desktop
      #latte-dock
    ];

  misc = [
      gnome-icon-theme
      #nuspell
      hunspell
      hunspellDicts.en-gb-ize
    ];

  kde = [
      discover
      # libsForQt5.kinfocenter # Info Centre
      libsForQt5.kdialog # QT Dialog boxes for shell scripts
      kate
  ];

}

