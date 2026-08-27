{
  config,
  lib,
  pkgs,
  ...
}:

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
      rustledger
    ];
    simonswine.neovim.lspconfig.beancount.cmd = [
      "${pkgs.rustledger}/bin/rledger-lsp"
    ];
  };
}
