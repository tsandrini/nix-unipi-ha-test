{
  description = "nix-unipi-ha-test";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, nixos-generators, ... }@inputs:
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

      packages.x86_64-linux.hapi-iso = nixos-generators.nixosGenerate {
        system = "aarch64-linux";
        format = "sd-aarch64";
        modules = [
          inputs.nixos-hardware.nixosModules.raspberry-pi-4
          ({config, pkgs, ...}: {

            sdImage.compressImage = false;
            sdImage.firmwareSize = 2048;

            system.stateVersion = "23.05";

            users.users.root.hashedPassword = "$6$7xwkdwWxSmBb5FYb$ZXtCEptSRyn8OWFBsOuT7tpw6UuJTq2MSE2RNEkjUoKZn0FBJ6AvqxhGeQSRSQQatFRT9jH35s3vN2iPrtz3b0
";
            services.home-assistant = {
              enable = true;
              # port = 8123;
              extraComponents = [
                "met"
                "radio_browser"
              ];
              config = {
                default_config = {};
                frontend = { };
                http = {
                  use_x_forwarded_for = true;
                  trusted_proxies = [
                    "127.0.0.1"
                    "::1"
                  ];
                };
              };
            };

            # Fix for the following issue
            # https://github.com/NixOS/nixpkgs/issues/154163
            nixpkgs.overlays = [
              (final: super: {
                makeModulesClosure = x:
                  super.makeModulesClosure (x // { allowMissing = true; });
              })
            ];
            # endfix
            #
            #
          })
        ];
      };
    };
}
