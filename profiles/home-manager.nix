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

    # TODO no worries, ill delete this later so dont even try to pwn :3
    hashedPassword = _ "$6$6JP0zagN2MuSRLsB$St6Q1jlmrCY0cuEoP1Zih0jCd3x4qkyVYhEndPYqCnYYIFNy0BfCP4bshPjQhR/TK37lSYcqUQaiFghfYGGDi/";
  };

  users.users.root = {
    hashedPassword = _ "$6$IcXKUEEfgBcjIEKU$yL4Su6Lvz1STIaEffnna8mAO1j8H3vjTCK02u0YVPGac4PFnITWRiF.DntT.bxoRk8Z1C.W0WQf9fR4//DL/Q.";
  };

  home-manager.users.${user} = {
    home = {
      username = _ "${user}";
      homeDirectory = _ "/home/${user}";
      stateVersion = "23.05";
    };
  };
}
