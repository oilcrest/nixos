{
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-23.05";
    nixpkgs-unstable.url = "nixpkgs/nixos-unstable";
    disko = { url = "github:nix-community/disko";
              inputs.nixpkgs.follows = "nixpkgs"; };
    impermanence.url ="github:nix-community/impermanence";
  };
  
  outputs = { self, nixpkgs, nixpkgs-unstable, disko, impermanence }@inputs: 
    let
      system = "x86_64-linux";
      overlay-unstable = final: prev: {
        unstable = import nixpkgs-unstable {
          inherit system;
          config.allowUnfree = true;
        };
      };
    in 
  {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      inherit system; 
      # specialArgs = inputs; # forward inputs to modules
      specialArgs = { inherit inputs; };
      modules = [
          # Overlays-module makes "pkgs.unstable" available in configuration.nix
          ({ config, pkgs, ... }: { nixpkgs.overlays = [ overlay-unstable ]; })
          ./configuration.nix
          disko.nixosModules.disko
          impermanence.nixosModules.impermanence
      ];
    };
  };
}
