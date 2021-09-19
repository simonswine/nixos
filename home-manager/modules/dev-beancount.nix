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
    simonswine.neovim = {
      plugins = with pkgs.vimPlugins; [ vim-beancount ];
      # TODO: lsp_servers.beancount see https://github.com/polarmutex/beancount-language-server
    };
  };
}
