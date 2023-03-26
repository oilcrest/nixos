# This is my NeoVim Nix Config file

{ config, pkgs, lib, ... }:
{
  # Neovim Config
  programs.neovim = {
    enable = true;
    configure = {
      customRC = ''
        set number
        set list
        "colorscheme duskfox 
        "colorscheme nightfox 
        "colorscheme terafox 
        "colorscheme tokyonight-moon 
        "colorscheme lunaperche 
        "colorscheme carbonfox 
        colorscheme kanagawa 
        "colorscheme embark 
      '';
      packages.myVimPackage = with pkgs.vimPlugins; {
        start = [ 
          vim-nix # Syntax highlight for nix files
          vim-commentary # Tim Pope's commentary plugin
          # Color Schemes
          tokyonight-nvim # tokyonight-moon is my fav
          nightfox-nvim # duskfox, nightfox, terafox & carbonfox
          kanagawa-nvim # Nice Japanese Vibe!
          embark-vim # An old favourite!
        ];
      };
    };
    viAlias = true;
    vimAlias = true;
  };
}
