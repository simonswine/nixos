{
  config,
  lib,
  pkgs,
  ...
}:

with lib;
let
  cfg = config.simonswine.dev.c;
in
{
  options.simonswine.dev.c = {
    enable = mkEnableOption "simonswine c/c++ development config";
  };

  config = mkIf cfg.enable {
    home.packages =
      with pkgs;
      [
        gcc
      ]
      ++ (
        if pkgs.stdenv.isLinux then
          [
            gdb
            elfutils
          ]
        else
          [ ]
      );

    simonswine.neovim.lspconfig.clangd.cmd = [
      "${pkgs.clang-tools}/bin/clangd"
    ];
  };
}
