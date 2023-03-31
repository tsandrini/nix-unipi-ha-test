{ config, pkgs, lib, inputs, user, ... }:
let _ = lib.mkOverride 500;
in {
  time.timeZone = _ "Europe/Prague";
  i18n.defaultLocale = _ "en_US.UTF-8";
}
