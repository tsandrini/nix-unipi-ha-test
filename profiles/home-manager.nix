{ config, pkgs, lib, inputs, user, ... }:
let _ = lib.mkOverride 500;
in {
  home-manager.useGlobalPkgs = _ true;
  home-manager.useUserPackages = _ true;

  users.mutableUsers = _ false;

  users.users.${user} = {
    isNormalUser = _ true;
    extraGroups =
      [ "wheel" "video" "audio" "camera" "networkmanager" "lightdm" ];
    home = _ "/home/${user}";
  };

  home-manager.users.${user} = {
    home = {
      username = _ "${user}";
      homeDirectory = _ "/home/${user}";
      stateVersion = "23.05";
    };
  };
}
