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
        delve
        go-junit-report
        go_1_17
        golangci-lint
        gopls
        gotags
        gotestsum
        modularise
      ];
      simonswine.neovim.plugins = with pkgs.vimPlugins; [
        vim-go
      ];
    };
}
