{
  lib,
  pkgs,
  config,
  ...
}:
with lib; let
  cfg = config.hello;
in {
  options.hello = {
    enable = mkEnableOption "hello service";
    greeter = mkOption {
      type = types.str;
      default = "world";
    };
  };

  config =
    mkIf cfg.enable {
    };
}
