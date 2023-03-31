{ config, pkgs, lib, inputs, user, ... }:
let _ = lib.mkOverride 500;
in {
  console = {
    enable = _ true;
    useXkbConfig = _ true;
    font = _ "ter-132n";
  };
}
