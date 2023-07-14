# packages.nix
{ config, pkgs, ... }: with pkgs;

rec {

# Packages I'm currentl testing out
# Once accepted place in another list
_testing = [];

# Package set names must differ from packages
# Otherwise recursion nastiness
my-package-set = builtins.concatLists [
    #_testing
    _shell 
    _cli
    _security
]; 

_shell = [
    zsh # Is this needed?
];

_cli = [
    direnv
    pv # progress viewer
    wget
    git
    htop
    nmap
    nvim
    unzip
    trash-cli
    neofetch
    efibootmgr # for managing efi
    zsh
];

_security = [
    lynis # security auditing tool
    clamav
];
}
