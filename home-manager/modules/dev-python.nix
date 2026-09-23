{
  config,
  lib,
  pkgs,
  ...
}:

with lib;
let
  cfg = config.simonswine.dev.python;
in
{
  options.simonswine.dev.python = {
    enable = mkEnableOption "simonswine python development config";
  };

  config = mkIf cfg.enable {
    simonswine.neovim = {
      lspconfig = {
        pyright = {
          cmd = [
            "${pkgs.pyright}/bin/pyright-langserver"
            "--stdio"
          ];
          settings.pyright.disableOrganizeImports = true;
        };

        ruff.cmd = [
          "${pkgs.ruff}/bin/ruff"
          "server"
        ];
      };

      conformConfig = {
        formatters_by_ft.python = [ "ruff_format" ];
        formatters.ruff_format.command = "${pkgs.ruff}/bin/ruff";
      };
    };
  };
}
