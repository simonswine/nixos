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
        # Use loginShellInit for login-specific variables
        loginShellInit = ''
          set -gx SHELL (which fish)
        '';
      };
    };
  };
}
