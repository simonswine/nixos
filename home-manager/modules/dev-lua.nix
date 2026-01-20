{
  config,
  lib,
  pkgs,
  ...
}:

with lib;
let
  cfg = config.simonswine.dev.lua;
in
{
  options.simonswine.dev.lua = {
    enable = mkEnableOption "simonswine lua development config";
  };

  config = mkIf cfg.enable {
    simonswine.neovim.lspconfig.lua_ls.cmd = [ "${pkgs.lua-language-server}/bin/lua-language-server" ];
  };
}
