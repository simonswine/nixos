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
      simonswine.dev.cad.enable = true;

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
        settings.show_startup_tips = false;
        settings.pane_viewport_serialization = true;
        settings.scrollback_lines_to_serialize = 10000;
        extraConfig = ''
          // --- falcode-zellij: floating agent-status popup ---
          keybinds {
              shared {
                  bind "Alt o" {
                      LaunchOrFocusPlugin "file:${config.xdg.configHome}/zellij/plugins/falcode-zellij-sessions.wasm" {
                          floating true
                          state_dir "${config.home.homeDirectory}/.local/state/falcode-zellij"
                      }
                  }
              }
          }

          // --- zellij-attention: tab icons while agents are working ---
          load_plugins {
              "file:${config.xdg.configHome}/zellij/plugins/zellij-attention.wasm" {
                  enabled "true"
                  waiting_icon "⏳"
                  completed_icon "✅"
              }
          }
        '';
      };

      # Install the zellij WASM plugins into ~/.config/zellij/plugins/
      xdg.configFile."zellij/plugins/falcode-zellij-sessions.wasm" = {
        source = "${pkgs.falcode-zellij}/lib/zellij/plugins/falcode-zellij-sessions.wasm";
      };
      xdg.configFile."zellij/plugins/zellij-attention.wasm" = {
        source = "${pkgs.zellij-attention}/lib/zellij/plugins/zellij-attention.wasm";
      };

      # OpenCode plugin: report agent status to falcode popup
      xdg.configFile."opencode/plugins/falcode.js" = {
        source = "${pkgs.falcode-zellij}/lib/opencode/plugins/falcode.js";
      };
      xdg.configFile."opencode/opencode.json" = {
        text = builtins.toJSON {
          "$schema" = "https://opencode.ai/config.json";
          plugin = [ "./plugins/falcode.js" ];
          instructions = [ "instructions.md" ];
        };
      };
      xdg.configFile."opencode/instructions.md".text = ''
        # Global Notes

        - Create new branches with `git checkout -b "$(date '+%Y%m%d_')<slug-description-of-change>"`.
      '';

      # Claude Code hook: report agent status + attention pipes to falcode state dir
      home.file.".local/state/falcode-zellij/falcode-hook.sh" = {
        source = "${pkgs.falcode-zellij}/lib/claude-extension/falcode-hook.sh";
        executable = true;
      };
      home.file.".local/state/falcode-zellij/oc-notify.sh" = {
        source = "${pkgs.falcode-zellij}/lib/scripts/oc-notify.sh";
        executable = true;
      };
      # Wire Claude hooks; merges into any existing settings via JSON merge
      home.file.".claude/settings.json" = {
        text = builtins.toJSON {
          includeCoAuthoredBy = false;
          includeGitStatus = false;
          enabledPlugins = {
            "slack@claude-plugins-official" = true;
          };
          extraKnownMarketplaces = {
            "claude-plugins-official" = {
              source = {
                source = "github";
                repo = "anthropics/claude-plugins-official";
              };
            };
          };
          hooks = {
            SessionStart = [
              { hooks = [ { type = "command"; command = "${config.home.homeDirectory}/.local/state/falcode-zellij/falcode-hook.sh SessionStart"; } ]; }
            ];
            UserPromptSubmit = [
              { hooks = [ { type = "command"; command = "${config.home.homeDirectory}/.local/state/falcode-zellij/falcode-hook.sh UserPromptSubmit"; } ]; }
            ];
            PreToolUse = [
              { hooks = [ { type = "command"; command = "${config.home.homeDirectory}/.local/state/falcode-zellij/falcode-hook.sh PreToolUse"; } ]; }
            ];
            PostToolUse = [
              { hooks = [ { type = "command"; command = "${config.home.homeDirectory}/.local/state/falcode-zellij/falcode-hook.sh PostToolUse"; } ]; }
            ];
            Notification = [
              { hooks = [ { type = "command"; command = "${config.home.homeDirectory}/.local/state/falcode-zellij/falcode-hook.sh Notification"; } ]; }
            ];
            Stop = [
              { hooks = [ { type = "command"; command = "${config.home.homeDirectory}/.local/state/falcode-zellij/falcode-hook.sh Stop"; } ]; }
            ];
            SessionEnd = [
              { hooks = [ { type = "command"; command = "${config.home.homeDirectory}/.local/state/falcode-zellij/falcode-hook.sh SessionEnd"; } ]; }
            ];
          };
        };
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
        opencode

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
