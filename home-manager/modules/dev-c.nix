{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.simonswine.dev.c;
in
{
  options.simonswine.dev.c = {
    enable = mkEnableOption "simonswine c/c++ development config";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      gcc
    ];
    simonswine.neovim =
      let
        lsp = [ "${pkgs.ccls}/bin/ccls" ];
      in
      {
        lsp_servers.c = lsp;
        lsp_servers.cpp = lsp;
      };
  };
}
