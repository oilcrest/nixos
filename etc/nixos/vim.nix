# This is my NeoVim Nix Config file

{ config, pkgs, lib, ... }:
{
  # Neovim Config
  programs.neovim = {
    enable = true;
    configure = {
      customRC = ''
        set number
        set relativenumber
        set list
        set tabstop=4
        set softtabstop=4
        set expandtab
        set shiftwidth=2
        set cursorline
        "colorscheme duskfox 
        colorscheme nightfox 
        "colorscheme terafox 
        "colorscheme tokyonight-moon 
        "colorscheme lunaperche 
        "colorscheme carbonfox 
        "colorscheme kanagawa 
        "colorscheme embark 
      '';
      packages.myVimPackage = with pkgs.vimPlugins; {
        start = [ 
          ale # Asynchronous Lint Engine (for e.g. shellcheck)
          vim-nix # Syntax highlight for nix files
          vim-commentary # Tim Pope's commentary plugin
          # Color Schemes
          tokyonight-nvim # tokyonight-moon is my fav
          nightfox-nvim # duskfox, nightfox, terafox & carbonfox
          kanagawa-nvim # Nice Japanese Vibe!
          embark-vim # An old favourite!
          lush-nvim # Needed by zenbones
          zenbones-nvim
        ];
      };
    };
    viAlias = true;
    vimAlias = true;
  };
}
