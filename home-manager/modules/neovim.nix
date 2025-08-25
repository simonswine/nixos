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
      };

      colorschemes.dracula-nvim.enable = true;

      lsp.servers =
        mapAttrs'
          (name: config:
            nameValuePair name {
              enable = true;
              settings = config;
            }
          )
          cfg.lspconfig;

      plugins = {
        lualine.enable = true;
        which-key.enable = true;

        # Show document outline
        aerial.enable = true;

        # TODO: Maybe needs more git plugins here (GBrowse, NeoGit)
        diffview.enable = true;

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
        nvim-tree.enable = true;

        neotest.enable = true;

        treesitter.enable = true;
        treesitter-context.enable = true;

        blink-cmp-dictionary.enable = true;
        blink-cmp-git.enable = true;
        blink-cmp-spell.enable = true;
        blink-emoji.enable = true;
        blink-ripgrep.enable = true;
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
                "git"
                "spell"
                "ripgrep"
              ];
              providers = {
                ripgrep = {
                  name = "Ripgrep";
                  module = "blink-ripgrep";
                  score_offset = 1;
                };
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
                git = {
                  name = "Git";
                  module = "blink-cmp-git";
                  enabled = true;
                  score_offset = 100;
                  should_show_items.__raw = ''
                    function()
                      return vim.o.filetype == 'gitcommit' or vim.o.filetype == 'markdown'
                    end
                  '';
                  opts = {
                    git_centers = {
                      github = {
                        issue = {
                          on_error.__raw = "function(_,_) return true end";
                        };
                      };
                    };
                  };
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

    programs.neovim = {
      enable = false;
      viAlias = true;
      vimAlias = true;
      vimdiffAlias = true;

      plugins = (with pkgs.vimPlugins; [
        vim-colors-solarized
        nerdtree

        # TODO cademichael/gotest.nvim

        telescope-nvim
        nui-nvim
        dressing-nvim
        plenary-nvim

        # Linting
        nvim-lint

        # Formatting
        conform-nvim

        # lua line
        lualine-nvim

        # ai completion
        avante-nvim

        # ai copilot
        copilot-lua
        copilot-cmp

        # debug adapter
        nvim-dap
        nvim-dap-ui

        # auto completion
        nvim-cmp
        cmp-buffer
        cmp-path
        cmp-cmdline
        cmp-nvim-lsp
        cmp-git

        render-markdown-nvim
        mini-nvim

        ack-vim

        nvim-lspconfig

        # git support for vim
        vim-fugitive
        vim-rhubarb

        # treesitter
        nvim-treesitter.withAllGrammars
        nvim-treesitter-context

      ]) ++ cfg.plugins;



      extraConfig =
        let
          lspconfigLua = builtins.concatStringsSep "\n" (
            attrValues (mapAttrs
              (name: config:
                "lspconfig.${name}.setup(ensure_capabilities(${generators.toLua {} config}))"
              )
              cfg.lspconfig));
        in
        ''
          " No temporary files in working directories
          set backupdir=~/.vim/backup//
          set directory=~/.vim/swap//
          set undodir=~/.vim/undo//

          " General settings
          set backspace=indent,eol,start
          set number
          set showcmd
          set incsearch
          set hlsearch

          " Required for operations modifying multiple buffers like rename.
          set hidden

          " Display position coordinates in bottom right
          set ruler

          " Abbreviate messages and disable intro screen
          set shortmess=atI

          " Automatically expand tabs into spaces
          set expandtab

          " Tabs are four spaces
          set shiftwidth=4
          set softtabstop=4
          set tabstop=4

          let mapleader=","

          "" Show whitespaces type
          set list
          set listchars=tab:>.,trail:.,extends:#,nbsp:.

          " fix background color erase
          let g:solarized_termtrans=1

          " Set the colorscheme
          set background=dark
          colorscheme solarized

          lua << EOF
          -- Set up nvim-cmp.
          local cmp = require'cmp'
          cmp.setup({
            snippet = {
              expand = function(args)
                vim.snippet.expand(args.body) -- For native neovim snippets (Neovim v0.10+)
              end,
            },
            mapping = cmp.mapping.preset.insert({
              ['<C-b>'] = cmp.mapping.scroll_docs(-4),
              ['<C-f>'] = cmp.mapping.scroll_docs(4),
              ['<C-Space>'] = cmp.mapping.complete(),
              ['<C-e>'] = cmp.mapping.abort(),
              ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
            }),
            sources = cmp.config.sources({
              { name = 'nvim_lsp', group_index = 2 },
              { name = 'copilot', group_index = 2 },
              { name = 'buffer', group_index = 3 },
            }),
          })

          -- Git commit completion.
          cmp.setup.filetype('gitcommit', {
              sources = cmp.config.sources({
                { name = 'git' },
              }, {
                { name = 'buffer' },
              })
           })
          require("cmp_git").setup()

          -- Setup lualine
          require('lualine').setup()

          -- Setup copilot
          require("copilot").setup({
            filetypes = {
              c = true,
              go = true,
              javascript = true,
              jsonnet = true,
              nix = true,
              python = true,
              rust = true,
              typescript = true,
              ["*"] = false, -- default disable
            },
            suggestion = { enabled = false },
            panel = { enabled = false },
          })
          require("copilot_cmp").setup()

          -- Setup avante ai assistant
          require('avante_lib').load()
          require('avante').setup({
            provider = 'claude',
          })

          -- Setup file/grep/windows
          local telescope = require('telescope.builtin')
          vim.keymap.set('n', '<leader>ff', telescope.find_files, { desc = 'Telescope find files' })
          vim.keymap.set('n', '<leader>fg', telescope.live_grep, { desc = 'Telescope live grep' })
          vim.keymap.set('n', '<leader>fb', telescope.buffers, { desc = 'Telescope buffers' })
          vim.keymap.set('n', '<leader>fh', telescope.help_tags, { desc = 'Telescope help tags' })
          vim.keymap.set('n', '<leader>fd', telescope.diagnostics, { desc = 'Telescope diagnostics' })
          vim.keymap.set('n', '<leader>fr', telescope.registers, { desc = 'Telescope registers' })

          -- Use buffer source for `/` and `?` (if you enabled `native_menu`, this won't work anymore).
          cmp.setup.cmdline({ '/', '?' }, {
            mapping = cmp.mapping.preset.cmdline(),
            sources = {
              { name = 'buffer' }
            }
          })

          -- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
          cmp.setup.cmdline(':', {
            mapping = cmp.mapping.preset.cmdline(),
            sources = cmp.config.sources({
              { name = 'path' }
            }, {
              { name = 'cmdline' }
            }),
            matching = { disallow_symbol_nonprefix_matching = false }
          })

          -- Setup formatting
          require("conform").setup(${generators.toLua {} cfg.conformConfig})
          vim.api.nvim_create_autocmd("BufWritePre", {
            pattern = "*",
            callback = function(args)
              require("conform").format({ bufnr = args.buf })
            end,
          })

          -- extraLuaConfig
          ${cfg.extraLuaConfig}
          -- end of extraLuaConfig

          local lspconfig = require('lspconfig')
          local capabilities = require('cmp_nvim_lsp').default_capabilities()
          local ensure_capabilities = function(params)
            params.capabilities = capabilities
            return params
          end

          -- Setup language servers.
          ${lspconfigLua}

          -- Global mappings.
          -- See `:help vim.diagnostic.*` for documentation on any of the below functions
          vim.keymap.set('n', '<space>e', vim.diagnostic.open_float)
          vim.keymap.set('n', '[d', vim.diagnostic.goto_prev)
          vim.keymap.set('n', ']d', vim.diagnostic.goto_next)
          vim.keymap.set('n', '<space>q', vim.diagnostic.setloclist)

          -- Use LspAttach autocommand to only map the following keys
          -- after the language server attaches to the current buffer
          vim.api.nvim_create_autocmd('LspAttach', {
            group = vim.api.nvim_create_augroup('UserLspConfig', {}),
            callback = function(ev)
              -- Enable completion triggered by <c-x><c-o>
              vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'

              -- Buffer local mappings.
              -- See `:help vim.lsp.*` for documentation on any of the below functions
              local opts = { buffer = ev.buf }
              vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
              vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
              vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
              vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
              vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)
              vim.keymap.set('n', '<space>wl', function()
                print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
              end, opts)
              vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition, opts)
              vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, opts)
              vim.keymap.set({ 'n', 'v' }, '<space>ca', vim.lsp.buf.code_action, opts)
              vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
              vim.keymap.set('n', '<space>f', function()
                vim.lsp.buf.format { async = true }
              end, opts)
            end,
          })

          require'nvim-treesitter.configs'.setup {
            highlight = {
              enable = true,
            },
            indent = {
              enable = true,
            },
          }

          EOF
        '' + cfg.extraConfig;
    };
    systemd.user.tmpfiles.rules = lib.mkIf pkgs.stdenv.isLinux [
      "d %h/.vim/backup 0700 - - -"
      "d %h/.vim/swap 0700 - - -"
      "d %h/.vim/undo 0700 - - -"
    ];
  };
}
