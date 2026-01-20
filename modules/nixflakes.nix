{
  config,
  lib,
  pkgs,
  ...
}:

with lib;
let
  cfg = config.programs.nixflakes;
in
{
  options.programs.nixflakes = with lib.types; {
    enable = mkEnableOption "Nix flakes";
  };

  config = mkIf cfg.enable {
    nix = {
      extraOptions = ''
        experimental-features = nix-command flakes
      '';
    };
    environment.systemPackages = with pkgs; [ git ];
  };
}
