{ config, pkgs, lib, inputs, user, ... }:
let _ = lib.mkOverride 500;
in {
  system.autoUpgrade = {
    enable = _ true;
    # TODO set autoupgrade flake when ready
    channel = _ "https://nixos.org/channels/nixos-unstable";
    allowReboot = _ true;
    randomizedDelaySec = _ "5m";
    rebootWindow = {
      lower = _ "02:00";
      upper = _ "05:00";
    };
  };

  nix = {
    gc = {
      automatic = _ true;
      dates = _ "weekly";
      options = _ "--delete-older-than 3d";
    };
    package = _ pkgs.nixVersions.unstable;
    registry.nixpkgs.flake = _ inputs.nixpkgs;
    settings.auto-optimise-store = _ true;
    extraOptions = lib.mkBefore ''
      experimental-features = nix-command flakes
      keep-outputs          = true
      keep-derivations      = true
    '';
  };
}
