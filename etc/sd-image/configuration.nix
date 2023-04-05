# Build image using the following command
#
# nix-build '<nixpkgs/nixos>' -A config.system.build.sdImage -I nixos-config=configuration.nix --argstr system aarch64-linux --option sandbox false
{ config, pkgs, inputs, user, lib, system, ... }: {

  imports = [
    # <nixpkgs/nixos/modules/installer/sd-card/sd-image-aarch64-installer.nix>
    pkgs.nixos.modules.installer.sd-card.sd-image-aarch64-installer
    inputs.nixos-hardware.nixosModules.raspberry-pi-4
  ];

  sdImage.compressImage = false;
  sdImage.firmwareSize = 1024;

  system.stateVersion = "23.05";
}
