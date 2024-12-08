{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.simonswine.dev.typescript;
in
{
  options.simonswine.dev.typescript = {
    enable = mkEnableOption "simonswine typescript development config";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      nodejs
      typescript
      nodePackages.yarn
    ];
    simonswine.neovim.lspconfig.ts_ls.cmd = [
      "${pkgs.nodePackages.typescript-language-server}/bin/typescript-language-server"
      "--stdio"

    ];
  };
}
