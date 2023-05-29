{
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-23.05";
    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";
    impermanence.url ="github:nix-community/impermanence";
  };
  outputs = { nixpkgs, disko, ... } @inputs: {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem rec {
      pkgs = import nixpkgs { inherit system; config = { allowUnfree = true; };};
      system = "x86_64-linux";
      specialArgs = inputs; # forward inputs to modules
      modules = [ ./configuration.nix
                  # This fixes nixpkgs (for e.g. "nix shell") to match the system nixpkgs
                  ({ config, pkgs, options, ... }: { nix.registry.nixpkgs.flake = nixpkgs; })
                  disko.nixosModules.disko
                ];
    };
  };
}
