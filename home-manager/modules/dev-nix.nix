{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.simonswine.dev.nix;
in
{
  options.simonswine.dev.nix = {
    enable = mkEnableOption "simonswine nix development config";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      nixpkgs-fmt
    ];
    simonswine.neovim = {
      plugins = with pkgs.vimPlugins; [ vim-nix ];
      lspconfig.nixd.cmd = [
        "${pkgs.nixd}/bin/nixd"
      ];
      conformConfig = {
        formatters_by_ft = {
          nix = [ "${pkgs.nixpkgs-fmt}/bin/nixpkgs-fmt" ];
        };
      };
    };
  };
}
