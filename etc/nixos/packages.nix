# This :qwis the packages.nix file
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

  testing = [
      get_iplayer
      mcfly
      helix # vim-like text editor
      nil # nix language server
      nodePackages.bash-language-server
      # antigen
      # zplug
      # fish
      cool-retro-term
      glxinfo
    ];

  my-package-set = builtins.concatLists [
      install
      testing
      cli
      #utils
      #gui
      #misc
      #kde
    ];

  # Base packages I want on initial install
  install = [
      direnv
      wget
      git
      unzip
      trash-cli
      neofetch
      efibootmgr
      zsh
      sqlite
    ];
      

  # testing = [
      # nix-software-center
      # ruby
      # crun
      # audacity
      # gramps
      # audacious
      # antigen
      # fish
      # cool-retro-term
      # glxinfo
      # salt
      # trickle # network bandwidth limiter
      # keyd # Key remapping daemon
      # youtube-dl
      # yt-dlp
      # obsidian
      # brave
      #sl
      #pkg-config
    # ];
  
  cli = [
      shellcheck
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

