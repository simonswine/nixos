{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.simonswine.dev.dotnet;
in
{
  options.simonswine.dev.dotnet = {
    enable = mkEnableOption "simonswine dotnet development config";
  };

  config = mkIf cfg.enable {
    simonswine.neovim.lspconfig.omnisharp.cmd = [
      "${pkgs.omnisharp-roslyn}/bin/OmniSharp"
    ];
  };
}
