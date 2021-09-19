{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.simonswine.dev.python;
in
{
  options.simonswine.dev.python = {
    enable = mkEnableOption "simonswine python development config";
  };

  config = mkIf cfg.enable {
    simonswine.neovim.lsp_servers.pyls = [ "${pkgs.python-language-server}/bin/pyls" ];
  };
}
