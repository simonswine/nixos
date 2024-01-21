{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.simonswine.neovim;

  packages = with pkgs.gnomeExtensions; [
    appindicator
    clipboard-indicator-2
    removable-drive-menu
    bluetooth-quick-connect
    sound-output-device-chooser
    vitals
    workspace-indicator
  ];
in
{
  options.simonswine.gnome-extensions = {
    enable = mkEnableOption "simonswine gnome extensions";
  };

  config = mkIf cfg.enable {
    home.packages = packages;

    dconf.settings = {
      # Enable installed extensions
      "org/gnome/shell".enabled-extensions = (map (extension: extension.extensionUuid) packages) ++ [
        "apps-menu@gnome-shell-extensions.gcampax.github.com"
        "appindicatorsupport@rgcjonas.gmail.com"
      ];

      "org/gnome/shell".disabled-extensions = [ ];

    };
  };
}
