{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.simonswine.zsh;
in
{
  options.simonswine.zsh = {
    enable = mkEnableOption "simonswine nvim config";

    lsp_servers = mkOption {
      default = { };
      type = types.attrsOf (types.listOf types.str);
    };

    plugins = mkOption {
      default = [ ];
    };

    extraConfig = mkOption {
      type = types.lines;
      default = "";
    };
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs;[
      fzf
      kubectl
      tmux
      direnv
    ];

    programs.zsh = {
      enable = true;
      oh-my-zsh = {
        enable = true;
        theme = "bira";
        plugins = [
          "git"
          "docker"
          "docker-compose"
          "golang"
          "fzf"
          "kubectl"
          "direnv"
        ];
      };
      history = {
        save = 1000000;
        size = 1000000;
      };
      enableCompletion = true;
      sessionVariables =
        {
          FZF_BASE = "${pkgs.fzf}/share/fzf";
        };
    };
  };
}
