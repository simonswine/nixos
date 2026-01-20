{
  config,
  lib,
  pkgs,
  ...
}:

with lib;
let
  cfg = config.simonswine.neovim;
in
{

  config = mkIf cfg.enable {

    programs.nixvim = {
      extraPlugins =
        let
          perfanno-nvim = pkgs.vimUtils.buildVimPlugin {
            pname = "perfanno.nvim";
            version = "2024-12-28";
            src = pkgs.fetchFromGitHub {
              owner = "t-troebst";
              repo = "perfanno.nvim";
              rev = "8640d6655f17a79af8de3153af2ce90c03f65e86";
              hash = "sha256-AfmmeLeUwYY9c3ISwt6/EHwCE4uhzKCvVoFwze7VJ4E=";
            };
            meta.homepage = "https://github.com/t-troebst/perfanno.nvim";
            meta.description = "Profiling Annotations and Call Graph Exploration in NeoVim!";
          };
        in
        [
          perfanno-nvim
        ];

      extraConfigLua = ''
        	require("perfanno").setup()
      '';

    };
  };
}
