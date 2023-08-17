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
    simonswine.neovim.lsp_servers.python = [ "${pkgs.python311Packages.python-lsp-server}/bin/pylsp" ];
  };
}
