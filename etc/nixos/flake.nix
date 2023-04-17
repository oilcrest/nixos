{
  description = "My NixOS System config";

  inputs = { self, nixpkgs }: {
    nixpkgs.url = "nixpkgs/nixos-22.09";
  };  
  outputs = { nixpkgs, ... }: 
  let
    system = "x86_64-linux";
    pkgs = import nixpkgs {
      inherit system;
      config = {allowUnfree = true; };
    };

    # overlays would go here
    
    # lib is where all the helper functions live
    lib = nixpkgs.lib;


  in {
    nixosConfigurations = {
      nixos = lib.nixosSystem { 
        iherit system;

        modules = [
          ./systemconfiguration.nix
        ];
      };
    };
  };
}
