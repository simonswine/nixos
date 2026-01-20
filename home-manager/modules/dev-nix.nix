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
          nixfmt = {
            command = "${pkgs.nixfmt}/bin/nixfmt";
          };
        };
        formatters_by_ft = {
          nix = [ "nixfmt" ];
        };
      };
    };
  };
}
