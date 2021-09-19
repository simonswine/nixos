{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.simonswine.dev.rust;
in
{
  options.simonswine.dev.rust = {
    enable = mkEnableOption "simonswine rust development config";
  };

  config = mkIf cfg.enable {
    # install core rust packages
    home.packages = with pkgs; [
      rustup
    ];

    simonswine.neovim = {
      extraConfig = ''
        " Rust
        autocmd BufWritePre *.rs :call LanguageClient#textDocument_formatting_sync()
      '';

      lsp_servers.rust = [ "${pkgs.rls}/bin/rls" ];
    };
  };
}
