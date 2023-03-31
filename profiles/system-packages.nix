{ config, pkgs, lib, inputs, user, ... }:
let _ = lib.mkOverride 500;
in {
  environment.systemPackages = with pkgs; [
    # BASE UTILS
    git
    htop
    wget
    curl
    killall
    openssl
    vim
    # HW
    exfat
    dosfstools
    exfatprogs
    udisks
    pciutils
    usbutils
  ];
}
