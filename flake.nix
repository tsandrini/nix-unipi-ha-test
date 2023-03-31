{
  description = "nix-unipi-ha-test";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs:
    let
      user = "tsandrini";
      lib = nixpkgs.lib;

      tensorlib = import ./lib {
        inherit (nixpkgs) lib;
        inherit inputs nixpkgs home-manager user;
      };

      findModules = dir:
        builtins.concatLists (builtins.attrValues (builtins.mapAttrs
          (name: type:
            if type == "regular" then [{
              name = builtins.elemAt (builtins.match "(.*)\\.nix" name) 0;
              value = import (dir + "/${name}");
            }] else if (builtins.readDir (dir + "/${name}"))
            ? "default.nix" then [{
              inherit name;
              value = import (dir + "/${name}");
            }] else
              findModules (dir + "/${name}")) (builtins.readDir dir)));

      mkHost = name:
        let
          system = lib.removeSuffix "\n"
            (builtins.readFile (./hosts + "/${name}/system"));
        in lib.nixosSystem {
          inherit system;
          specialArgs = {
            inherit inputs user;
            host.hostName = name;
          };
          modules = [
            { nixpkgs.config.allowUnfree = true; }
            { networking.hostName = name; }
            (./hosts + "/${name}")
          ];
        };
    in {
      nixosModules = builtins.listToAttrs (findModules ./modules);

      nixosProfiles = builtins.listToAttrs (findModules ./profiles);

      nixosRoles = import ./roles;

      nixosConfigurations =
        (let hosts = builtins.attrNames (builtins.readDir ./hosts);
        in lib.genAttrs hosts mkHost);

    };
}
