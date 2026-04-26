{
  config,
  lib,
  pkgs,
  ...
}:

with lib;
let
  cfg = config.simonswine.dev.cad;
in
{
  options.simonswine.dev.cad = {
    enable = mkEnableOption "simonswine CAD config";
  };

  config = mkIf cfg.enable {
    simonswine.neovim.lspconfig.openscad_lsp.cmd = [
      "${pkgs.openscad-lsp}/bin/openscad-lsp"
      "--stdio"
    ];

    home.packages = [ pkgs.fluidcad ];

    programs.nixvim = {
      extraPlugins = [ pkgs.fluidcad-nvim ];

      extraConfigLua = ''
        require("fluidcad").setup({})
      '';
    };
  };
}
