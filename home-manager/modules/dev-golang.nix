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
      default = pkgs.go_1_23;
      defaultText = literalExpression "pkgs.go_1_20";
      description = ''
        Which package to use for Go.
      '';
    };

    delvePackage = mkOption {
      type = types.package;
      default = pkgs.delve;
      defaultText = literalExpression "pkgs.delve";
      description = ''
        Which package to use for delve.
      '';
    };

  };

  config = mkIf cfg.enable (mkMerge [
    {
      # install core golang dev packages
      home.packages = with pkgs; [
        cfg.delvePackage
        go-junit-report
        cfg.package
        golangci-lint
        gopls
        gotags
        gotestsum
        modularise
        benchstat
        gopatch
        gotests
        iferr
        gotestsum
        impl
        mockgen
        gotools # for goimports
      ];
      simonswine.neovim = {
        lspconfig.gopls.cmd = [
          "${pkgs.gopls}/bin/gopls"
        ];
        lspconfig.golangci_lint_ls.cmd = [
          "${pkgs.golangci-lint-langserver}/bin/golangci-lint-langserver"
        ];
        plugins = with pkgs.vimPlugins; [
          nvim-dap-go
        ];
        extraLuaConfig = ''
          require('dap-go').setup()
        '';
        conformConfig = {
          formatters_by_ft = {
            go = [ "gofmt" "goimports" ];
          };
        };
      };
    }
  ]);
}
