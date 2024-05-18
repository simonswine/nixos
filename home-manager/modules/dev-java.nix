{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.simonswine.dev.java;
in
{
  options.simonswine.dev.java = {
    enable = mkEnableOption "simonswine java development config";
  };

  config = mkIf cfg.enable {
    simonswine.neovim.lspconfig.jdtls.cmd = [
      "${pkgs.jdt-language-server}/bin/jdt-language-server"
    ];
  };
}
