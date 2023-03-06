{ config, pkgs, lib, ... }:
let
  cfg = config.services.g810-led;
in
with lib;

{
  options.services.g810-led = {
    enable = mkEnableOption "g810-led";

    package = mkOption {
      type = types.package;
      default = pkgs.g810-led;
      defaultText = literalExpression "pkgs.g810-led";
    };

    config = mkOption {
      default = ''
        a ffffff # Set all keys white
        c        # Commit changes
      '';
      type = types.str;
    };
  };

  config = mkIf cfg.enable {
    systemd.packages = [
      cfg.package
    ];
    services.udev.packages = [
      cfg.package
    ];
    environment.etc."g810-led/profile".text = cfg.config;
  };
}
