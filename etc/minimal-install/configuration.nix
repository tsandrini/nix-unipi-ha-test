{ config, pkgs, lib, ... }: {
  # -----------------
  # | SPECIFICATION |
  # -----------------
  # Model: Lenovo B51-80

  # --------------------------
  # | ROLES & MODULES & etc. |
  # --------------------------
  imports = [
    ./hardware-configuration.nix
    "${fetchTarball "https://github.com/NixOS/nixos-hardware/archive/936e4649098d6a5e0762058cb7687be1b2d90550.tar.gz" }/raspberry-pi/4"
  ];

  # ------------------------------
  # | ADDITIONAL SYSTEM PACKAGES |
  # ------------------------------
  environment.systemPackages = with pkgs; [
    git
    curl
    wget
    htop
    openssl
    vim
    exfat
    dosfstools
    exfatprogs
    udisks
    pciutils
    usbutils
  ];

  hardware.enableRedistributableFirmware = true;
  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = true;
  };

  programs.ssh.startAgent = true;
}
