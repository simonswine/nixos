{
  config,
  lib,
  pkgs,
  ...
}:

with lib;
let
  cfg = config.simonswine.dev.rego;
in
{
  options.simonswine.dev.rego = {
    enable = mkEnableOption "simonswine rego development config";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      open-policy-agent
    ];
    simonswine.neovim =
      let
        vim-rego = pkgs.vimUtils.buildVimPlugin {
          name = "vim-rego";
          src = pkgs.fetchFromGitHub {
            owner = "tsandall";
            repo = "vim-rego";
            rev = "c383f053acee421a1bd01b2351df52ab09d2323f";
            sha256 = "sha256-m6BxTGY4QHaAO70VdxLhZBqQT/hvtUE+xS5Jl7gjuUU=";
          };
        };
      in
      {
        plugins = with pkgs.vimPlugins; [ vim-rego ];
        extraConfig = ''
          " Rego auto format
          let g:formatdef_rego = '"${pkgs.open-policy-agent}/bin/opa fmt"'
          let g:formatters_rego = ['rego']
          let g:autoformat_autoindent = 0
          let g:autoformat_retab = 0
          au BufWritePre *.rego Autoformat

        '';
      };
  };
}
