# packages.nix
{ config, pkgs, ... }: with pkgs;

rec {

# Packages I'm currentl testing out
# Once accepted place in another list
_testing = [
    obsidian
    get_iplayer
    cool-retro-term
    glxinfo        
];

# Package set names must differ from packages
# Otherwise recursion nastiness
my-package-set = builtins.concatLists [
    _testing
    _helix # Packages relating to helix
    _shell 
    _cli
    # security
    # gui
    # browsers
    _misc
    _kde # kde-specific packages
    _scripting
    # install
]; 


_helix = [
    helix
    nil # nix lsp
    nodePackages.bash-language-server # bash lsp
];

_shell = [
    zsh # Is this needed?
    mcfly # cross-shell command line history    
];

_cli = [
    # shellcheck # is this still needed?
    direnv
    pv # progress viewer
    wget
    git
    unzip
    # appimage-run
    trash-cli
    neofetch
    efibootmgr # for managing efi
    zsh
    # distrobox
    
    # Are these needed?
    # xorg.xhost
    # spice-vdagent
    # x11spice
];

_security = [
    firejail
    lynis # security auditing tool
];

_gui = [
    gparted # disk formatting
    glxinfo # =glxgears
    filelight # disk usage
    logseq
    # signal-desktop
];

_browsers = [
    firefox
    librewolf # hardened ff
    # unboogled-chromium
];

_misc = [
    gnome-icon-theme
    hunspell
    hunspellDicts.en-gb-ize
];

# Only include these if desktop is kde
_kde = (if (config.myDesktop == "kde") then
[
    discover
    # packagekit
    # libsForQt5.packagekit-qt
    # libsForQt5.kinfocenter # Info center
    # latte-dock
] else [ ]);

_scripting = [
    libsForQt5.kdialog # QT Dialog boxes for shell scripts
    nix-prefetch-docker # used to get hash info for building docker images with nix
    desktop-file-utils # set of cli tools for .desktop files
    # gettext # what is this?
];

# A minimal set of packages for install
_install = [
    direnv
    wget
    git
    unzip
    trash-cli
    neofetch
    efibootmgr # for managing efi
    zsh
    sqlite # needed for histdb    
];

}
