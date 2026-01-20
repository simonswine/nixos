{
  config,
  lib,
  pkgs,
  ...
}:

with lib;
let
  cfg = config.simonswine.desktop;
in

{
  options.simonswine.desktop = {
    enable = mkEnableOption "simonswine's desktop config";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      mpv
    ];
  };
}
