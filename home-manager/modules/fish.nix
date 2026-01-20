{
  config,
  lib,
  pkgs,
  ...
}:

with lib;
let
  cfg = config.simonswine.fish;
in
{
  options.simonswine.fish = {
    enable = mkEnableOption "simonswine fish config";
  };

  config = mkIf cfg.enable {
    programs = {

      atuin.enableFishIntegration = true;
      fish = {
        enable = true;
      };
    };
  };
}
