# packages.nix
{ config, pkgs, ... }: with pkgs;

rec {

# Packages I'm currentl testing out
# Once accepted place in another list
_testing = [
    unstable.obsidian
    exa
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
    _DE # DE specific packages
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
    aspell
    aspellDicts.en
    # hunspell
    # hunspellDicts.en-gb-ize
];

# Desktop Specific packages
_DE = (
if (config.myDesktop == "kde") then
[
    discover
    libsForQt5.kate
    # packagekit
    # libsForQt5.packagekit-qt
    # libsForQt5.kinfocenter # Info center
    # latte-dock
] 
else if (config.myDesktop == "pantheon") then
[
    gsettings-desktop-schemas
]
else [ ]);

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
