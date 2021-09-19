{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.simonswine.dev.ruby;
in
{
  options.simonswine.dev.ruby = {
    enable = mkEnableOption "simonswine ruby development config";
  };

  config = mkIf cfg.enable {
    simonswine.neovim.lsp_servers.ruby = [ "${pkgs.solargraph}/bin/solargraph" "stdio" ];
  };
}
