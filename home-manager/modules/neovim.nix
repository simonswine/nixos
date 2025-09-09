{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.simonswine.neovim;
in
{
  options.simonswine.neovim = {
    enable = mkEnableOption "simonswine nvim config";

    lspconfig = mkOption {
      default = { };
      type = types.attrsOf types.anything;
    };

    conformConfig = mkOption {
      default = {
        formatters = {
          fixjson = {
            command = "${pkgs.fixjson}/bin/fixjson";
          };
        };
        formatters_by_ft = {
          json5 = [ "fixjson" ];
        };
      };
      type = types.attrsOf types.anything;
    };

    lintConfig = mkOption {
      default = { };
      type = types.attrsOf types.anything;
    };

    plugins = mkOption {
      default = [ ];
    };

    extraConfig = mkOption {
      type = types.lines;
      default = "";
    };

    extraLuaConfig = mkOption {
      type = types.lines;
      default = "";
    };
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      fd
      fixjson
      ripgrep
    ];

    programs.tmux.extraConfig = ''
      # Support true color
      set-option -a terminal-features 'screen-256color:RGB'

      # Reduce escape time for better compatibilty with nvim
      set-option -sg escape-time 10
    '';

    programs.nixvim = {
      viAlias = true;
      vimAlias = true;
      vimdiffAlias = true;
      enable = true;

      globals = {
        mapleader = ",";
      };

      clipboard = {
        register = "unnamedplus";
      };

      opts = {
        number = true; # Show line numbers
        relativenumber = true; # Show numbers relative to cursor

        grepprg = "rg --vimgrep --smart-case --follow"; # Replace grep with ripgrep

        expandtab = false;
        tabstop = 4; # Set indentation of tabs to be equal to 4 spaces.
        shiftwidth = 4;
        softtabstop = 4;

        # highlight certain whitespace characters
        list = true;
        listchars = {
          tab = ">.";
          trail = ".";
          extends = "#";
          nbsp = ".";
        };
      };

      extraPlugins = with pkgs.vimPlugins; [
        outline-nvim
        vim-fugitive
        vim-rhubarb
      ];
      extraConfigLua = ''
        require("outline").setup {}
      '';

      colorschemes.catppuccin = {
        enable = true;
        settings = {
          transparent_background = true;
          integrations = {
            diffview = true;
            native_lsp.enabled = true;
            neotest = true;
            neotree = true;
            telescope.enabled = true;
            which_key = true;
          };
        };
      };

      lsp = {
        luaConfig.post = ''
          vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, { border = "rounded" })

          vim.diagnostic.config({
            virtual_text = true,
            signs = true,
            underline = true,
            update_in_insert = true,
            severity_sort = false,
          })
        '';
        servers =
          mapAttrs'
            (name: config:
              nameValuePair name {
                enable = true;
                settings = config;
              }
            )
            cfg.lspconfig;
      };

      keymaps = [
        {
          mode = [ "n" ];
          action = "<cmd>Outline<CR>";
          key = "<leader>o";
          options = {
            desc = "Toggle file outline.";
          };
        }
        # LSP Keymaps
        {
          mode = [ "n" ];
          action = "<cmd>lua vim.lsp.buf.declaration()<CR>";
          key = "gD";
          options = {
            desc = "Go to declaration.";
            silent = true;
          };
        }
        {
          mode = [ "n" ];
          action = "<cmd>lua vim.lsp.buf.definition()<CR>";
          key = "gd";
          options = {
            desc = "Go to definition.";
            silent = true;
          };
        }
        {
          mode = [ "n" ];
          action = "<cmd>lua vim.lsp.buf.type_definition()<CR>";
          key = "gy";
          options = {
            desc = "Go to type definition.";
            silent = true;
          };
        }
        {
          mode = [ "n" ];
          action = "<cmd>lua vim.lsp.buf.hover()<CR>";
          key = "K";
          options = {
            desc = "Show more information";
            silent = true;
          };
        }
        {
          mode = [ "n" ];
          action = "<cmd>vim.lsp.buf.implementation()<CR>";
          key = "gi";
          options = {
            desc = "Go to implementation.";
            silent = true;
          };
        }
      ];

      plugins = {
        lualine.enable = true;
        which-key.enable = true;

        # Enable git helpers
        diffview.enable = true;
        gitlinker.enable = true;
        gitsigns.enable = true;

        render-markdown.enable = true;

        web-devicons.enable = true;

        # Support debugging
        dap.enable = true;
        dap-ui.enable = true;

        # Code completion
        minuet = {
          enable = true;
          package = pkgs.vimPlugins.minuet-ai-nvim.overrideAttrs (old: {
            patches = (old.patches or [ ]) ++ [
              ./neovim/plugins/minuet-ai-nvim/add-title-headers.patch
            ];
          });
          settings = {
            request_timeout = 3;
            throttle = 1000;
            debounce = 300;
            provider = "openai_compatible";
            provider_options = {
              openai_compatible = {
                api_key = "OPENROUTER_API_KEY";
                end_point = "https://openrouter.ai/api/v1/chat/completions";
                model = "mistralai/devstral-small-2505";
                name = "OpenRouter";
                optional = {
                  max_tokens = 256;
                  top_p = 0.9;
                  provider = {
                    # Prioritize throughput for faster completion
                    sort = "throughput";
                  };
                };
                stream = true;
              };
            };
          };
        };

        conform-nvim = {
          enable = true;
          settings = {
            format_on_save = {
              timeout_ms = 500;
              lsp_format = "fallback";
            };
          } // cfg.conformConfig;

        };

        lint = cfg.lintConfig // {
          enable = true;
        };

        lspconfig.enable = true;
        neo-tree.enable = true;

        neotest.enable = true;

        treesitter = {
          enable = true;
          settings.highlight.enable = true;
        };
        treesitter-context.enable = true;

        blink-cmp-dictionary.enable = true;
        blink-cmp-spell.enable = true;
        blink-emoji.enable = true;
        blink-cmp = {
          enable = true;
          setupLspCapabilities = true;

          settings = {
            keymap = {
              "<C-space>" = [
                "show"
                "show_documentation"
                "hide_documentation"
              ];
              "<C-e>" = [
                "hide"
                "fallback"
              ];
              "<CR>" = [
                "accept"
                "fallback"
              ];
              "<Tab>" = [
                "select_next"
                "snippet_forward"
                "fallback"
              ];
              "<S-Tab>" = [
                "select_prev"
                "snippet_backward"
                "fallback"
              ];
              "<Up>" = [
                "select_prev"
                "fallback"
              ];
              "<Down>" = [
                "select_next"
                "fallback"
              ];
              "<C-p>" = [
                "select_prev"
                "fallback"
              ];
              "<C-n>" = [
                "select_next"
                "fallback"
              ];
              "<C-up>" = [
                "scroll_documentation_up"
                "fallback"
              ];
              "<C-down>" = [
                "scroll_documentation_down"
                "fallback"
              ];
              "<A-y>" = config.lib.nixvim.mkRaw ''{
                function (cmp)
                    cmp.show { providers = {'minuet'} }
                end,
			  }'';
            };
            signature = {
              enabled = true;
              window = {
                border = "rounded";
              };
            };

            sources = {
              default = [
                "buffer"
                "lsp"
                "path"
                "snippets"
                # Community
                "dictionary"
                "emoji"
                "spell"
              ];
              providers = {
                dictionary = {
                  name = "Dict";
                  module = "blink-cmp-dictionary";
                  min_keyword_length = 3;
                };
                emoji = {
                  name = "Emoji";
                  module = "blink-emoji";
                  score_offset = 1;
                };
                minuet = {
                  name = "minuet";
                  module = "minuet.blink";
                  async = true;
                  timeout_ms = 3000;
                  score_offset = 50;
                };
                lsp.score_offset = 4;
                spell = {
                  name = "Spell";
                  module = "blink-cmp-spell";
                  score_offset = 1;
                };
              };
            };

            appearance = {
              nerd_font_variant = "mono";
              kind_icons = {
                Text = "󰉿";
                Method = "";
                Function = "󰊕";
                Constructor = "󰒓";

                Field = "󰜢";
                Variable = "󰆦";
                Property = "󰖷";

                Class = "󱡠";
                Interface = "󱡠";
                Struct = "󱡠";
                Module = "󰅩";

                Unit = "󰪚";
                Value = "󰦨";
                Enum = "󰦨";
                EnumMember = "󰦨";

                Keyword = "󰻾";
                Constant = "󰏿";

                Snippet = "󱄽";
                Color = "󰏘";
                File = "󰈔";
                Reference = "󰬲";
                Folder = "󰉋";
                Event = "󱐋";
                Operator = "󰪚";
                TypeParameter = "󰬛";
                Error = "󰏭";
                Warning = "󰏯";
                Information = "󰏮";
                Hint = "󰏭";

                Emoji = "🤶";
              };
            };
            completion = {
              menu = {
                border = "none";
                draw = {
                  gap = 1;
                  treesitter = [ "lsp" ];
                  columns = [
                    {
                      __unkeyed-1 = "label";
                    }
                    {
                      __unkeyed-1 = "kind_icon";
                      __unkeyed-2 = "kind";
                      gap = 1;
                    }
                    { __unkeyed-1 = "source_name"; }
                  ];
                };
              };
              trigger = {
                show_in_snippet = false;
              };
              documentation = {
                auto_show = true;
                window = {
                  border = "single";
                };
              };
              accept = {
                auto_brackets = {
                  enabled = false;
                };
              };
            };
          };
        };

        telescope = {
          enable = true;
          keymaps = {
            "<leader>ff" = {
              action = "find_files";
              options = {
                desc = "Telescope find files";
              };
            };
            "<leader>fg" = {
              action = "live_grep";
              options = {
                desc = "Telescope live grep";
              };
            };
            "<leader>fb" = {
              action = "buffers";
              options = {
                desc = "Telescope buffers";
              };
            };
            "<leader>fh" = {
              action = "help_tags";
              options = {
                desc = "Telescope help tags";
              };
            };
            "<leader>fd" = {
              action = "diagnostics";
              options = {
                desc = "Telescope diagnostics";
              };
            };
            "<leader>fr" = {
              action = "registers";
              options = {
                desc = "Telescope registers";
              };
            };
          };
        };
      };
    };

    systemd.user.tmpfiles.rules = lib.mkIf pkgs.stdenv.isLinux [
      "d %h/.vim/backup 0700 - - -"
      "d %h/.vim/swap 0700 - - -"
      "d %h/.vim/undo 0700 - - -"
    ];
  };
}
