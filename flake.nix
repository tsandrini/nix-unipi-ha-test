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

            # -------------
            # | IMAGE MOD |
            # -------------
            sdImage.compressImage = false;
            sdImage.firmwareSize = 1024;

            system.stateVersion = "23.05";

            # ------------
            # | SYS PKGS |
            # ------------
            environment.systemPackages = with pkgs; [
              git
              htop
              btop
              wget
              curl
              killall
              openssl
              vim
            ];

            # ------
            # | SYS |
            # -------
            nixpkgs.config.allowUnfree = true;
            networking.hostName = "hapi";
            users.users.root.hashedPassword = "$6$y4YHckhbQeRqtREj$qf/D61Tn4KZnd4RTznXccm9JC1Qj9TWnLVHW6U59LRwKfoO3MBUHuBj7LLVBC.m5WScUvp88EgVz2/4qFyZ.o.";
            services.getty.autologinUser = "root";

            services.openssh = {
              enable = true;
              settings.PasswordAuthentication = true;
              settings.PermitRootLogin = "yes"; # testing only
            };
            programs.ssh.startAgent = true;

            time.timeZone = "Europe/Prague";
            i18n.defaultLocale = "en_US.UTF-8";
            networking.firewall.enable = false;
            networking.networkmanager.enable = true;

            console = {
              enable = true;
              useXkbConfig = true;
              font = "ter-132n";
            };

            # ------
            # | SYS |
            # -------
            system.autoUpgrade = {
              enable = true;
              # flake  = "github:tsandrini/nix-unipi-ha-test#hapi";
              channel = "https://nixos.org/channels/nixos-unstable";
              allowReboot = true;
              randomizedDelaySec = "5m";
              rebootWindow = {
                lower = "02:00";
                upper = "03:00";
              };
            };

            nix = {
              gc = {
                automatic = true;
                dates = "weekly";
                options = "--delete-older-than 3d";
              };
              package = pkgs.nixVersions.unstable;
              registry.nixpkgs.flake = inputs.nixpkgs;
              settings.auto-optimise-store = true;
              extraOptions = lib.mkBefore ''
                experimental-features = nix-command flakes
                keep-outputs          = true
                keep-derivations      = true
              '';
            };

            # ------------------
            # | HOME ASSISTANT |
            # ------------------
            services.home-assistant = {
              enable = true;
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
                    "10.0.0.0/24"
                    "192.168.33.0/24"
                  ];
                };
              };
              package = (pkgs.home-assistant.override {
                extraPackages = py: with py; [ psycopg2 ];
              }).overrideAttrs (oldAttrs: {
                doInstallCheck = false;
              });
              config.recorder.db_url = "postgresql://@/hass";
            };

            services.postgresql = {
              enable = true;
              ensureDatabases = [ "hass" ];
              ensureUsers = [{
                name = "hass";
                ensurePermissions = {
                  "DATABASE hass" = "ALL PRIVILEGES";
                };
              }];
            };

            services.node-red = {
              enable = true;
              port = 1880;
              openFirewall = true;
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
          })
        ];
      };
    };
}
