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
      lintConfig = {
        lintersByFt = {
          nix = [ "statix" ];
        };
        linters = {
          statix = {
            cmd = "${pkgs.statix}/bin/statix";
          };
        };
      };
      conformConfig = {
        formatters = {
          nixpkgs_fmt = {
            command = "${pkgs.nixpkgs-fmt}/bin/nixpkgs-fmt";
          };
        };
        formatters_by_ft = {
          nix = [ "nixpkgs_fmt" ];
        };
      };
    };
  };
}
