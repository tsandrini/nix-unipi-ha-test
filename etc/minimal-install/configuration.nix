{ config, pkgs, inputs, user, lib, system, ... }: {
  # --------------------------
  # | ROLES & MODULES & etc. |
  # --------------------------
  imports = with inputs.self; [
    ./hardware-configuration.nix
    inputs.nixos-hardware.nixosModules.raspberry-pi-4
  ];

  # ------------------------------
  # | ADDITIONAL SYSTEM PACKAGES |
  # ------------------------------
  environment.systemPackages = with pkgs; [ ];

  # ----------------------------
  # | ADDITIONAL USER PACKAGES |
  # ----------------------------
  home-manager.users.${user} = { home.packages = with pkgs; [ ]; };

  # hardware.enableRedistributableFirmware = true;

  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = true;
  };

  programs.ssh.startAgent = true;
  # services.home-assistant = {
  #   enable = true;
  #   # port = 8123;
  #   extraComponents = [
  #     "met"
  #     "radio_browser"
  #   ];
  #   config = {
  #     default_config = {};
  #     frontend = { };
  #     http = {
  #       use_x_forwarded_for = true;
  #       trusted_proxies = [
  #         "127.0.0.1"
  #         "::1"
  #       ];
  #     };
  #   };
  # };

}
