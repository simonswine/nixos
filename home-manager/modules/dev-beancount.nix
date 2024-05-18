{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.simonswine.dev.beancount;
in
{
  options.simonswine.dev.beancount = {
    enable = mkEnableOption "simonswine beancount development config";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      beancount
      fava
    ];
    simonswine.neovim.lspconfig.beancount.cmd = [
      "${pkgs.beancount-language-server}/bin/beancount-language-server"
      "--stdio"
    ];
  };
}
