{
  config,
  lib,
  pkgs,
  ...
}:

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
    (mkIf cfg.personal {
      simonswine.dev.golang.enable = true;
      simonswine.dev.nix.enable = true;
      simonswine.dev.python.enable = true;
      simonswine.dev.rust.enable = true;
      simonswine.dev.c.enable = true;
      simonswine.dev.ruby.enable = true;
      simonswine.dev.jsonnet.enable = true;
      simonswine.dev.beancount.enable = true;
      simonswine.dev.lua.enable = true;

      programs.gh = {
        enable = true;
        settings.aliases = {
          co = ''!id="$(gh pr list -L100 | fzf | cut -f1)"; [ -n "$id" ] && gh pr checkout "$id"'';
        };
      };

      programs.git = {
        enable = true;

        settings = {
          user = {
            name = "Christian Simon";
            email = "simon@swine.de";
            signingkey = "D29F745DD48CA0E0C33A7B081FF2C09C62045ED2";
          };
          init.defaultBranch = "main";

          alias = {
            hist = ''log --pretty=format:"%h %ad | %s%d [%an]" --graph'';
          };

          merge = {
            conflictStyle = "diff3";
            tool = "vimdiff";
          };
          mergetool.prompt = false;

          pull.rebase = false;
          push.default = "simple";

          core.fsmonitor = true;
          core.untrackedcache = true;
        };

        ignores = [
          "/.perfgo/"
          "/.claude/"
          "/.idea/"
          "/.ctags"
          "/tags"
          "/tags.lock"
          "/tags.temp"
          "/.ropeproject"
          ".envrc"
          ".direnv/"
          "*~"
          "*.swp"
        ];
      };

      home.packages = with pkgs; [
        git
        git-crypt
      ];

    })
    (mkIf cfg.grafanaLabs {
      simonswine.dev.golang.enable = true;
      simonswine.dev.jsonnet.enable = true;
      simonswine.dev.typescript.enable = true;
      simonswine.dev.rego.enable = true;
      simonswine.dev.dotnet.enable = true;
      simonswine.dev.java.enable = true;

      programs.git.settings.url = {
        "ssh://git@github.com/grafana/" = {
          insteadOf = "https://github.com/grafana/";
        };
      };

      programs.zellij = {
        enable = true;
        settings.theme = "catppuccin";
      };

      home.packages = with pkgs; [
        drone-cli
        glow

        # add cloud-provider tools
        (google-cloud-sdk.withExtraComponents [ google-cloud-sdk.components.gke-gcloud-auth-plugin ])
        awscli2
        (azure-cli.withExtensions [
          azure-cli-extensions.account
        ])

        # logcli
        grafana-loki

        # ai stuff
        claude-code
        crush

        # protobuf
        protoscope

        devfiler
      ];
    })
    {
      simonswine.neovim.lspconfig.harper_ls.cmd = [
        "${pkgs.harper}/bin/harper-ls"
        "--stdio"
      ];
    }
  ];
}
