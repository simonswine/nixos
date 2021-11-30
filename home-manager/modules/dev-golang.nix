{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.simonswine.dev.golang;
in
{
  options.simonswine.dev.golang = {
    enable = mkEnableOption "simonswine golang development config";
  };

  config =
    mkIf cfg.enable {
      # install core golang dev packages
      home.packages = with pkgs; [
        go_1_17
        delve
        golangci-lint
        go-junit-report
        gotestsum
        gopls
        gotags
      ];
      simonswine.neovim.plugins = with pkgs.vimPlugins; [
        vim-go
      ];
    };
}
