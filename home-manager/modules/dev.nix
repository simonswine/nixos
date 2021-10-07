{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.simonswine.dev.preset;
in
{
  options.simonswine.dev.preset = {
    personal = mkEnableOption "simonswine's personal development config";
    grafanaLabs = mkEnableOption "simonswine's Grafana Labs development config";
  };

  config = mkMerge [
    (mkIf cfg.personal
      {
        simonswine.dev.golang.enable = true;
        simonswine.dev.nix.enable = true;
        simonswine.dev.python.enable = true;
        simonswine.dev.rust.enable = true;
        simonswine.dev.c.enable = true;
        simonswine.dev.ruby.enable = true;
        simonswine.dev.jsonnet.enable = true;
        simonswine.dev.beancount.enable = true;

      }
    )
    (mkIf cfg.grafanaLabs
      {
        simonswine.dev.golang.enable = true;
        simonswine.dev.jsonnet.enable = true;
        simonswine.dev.typescript.enable = true;
        simonswine.dev.rego.enable = true;
      }
    )
  ];
}