{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.simonswine.dev.golang;
in
{
  options.simonswine.dev.golang = {
    enable = mkEnableOption "simonswine golang development config";

    package = mkOption {
      type = types.package;
      default = pkgs.go_1_18;
      defaultText = literalExpression "pkgs.go_1_17";
      description = ''
        Which package to use for Go.
      '';
    };


  };

  config =
    mkIf cfg.enable {

      home.sessionVariables = {
        GOROOT = "${cfg.package}/share/go";
      };

      # install core golang dev packages
      home.packages = with pkgs; [
        delve
        go-junit-report
        cfg.package
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
