{ config, pkgs, lib, inputs, user, ... }:
let _ = lib.mkOverride 500;
in {
  networking.networkmanager.enable = _ true;
}
