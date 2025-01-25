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
      default = { };
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
    ];

    programs.tmux.extraConfig = ''
      # Support true color
      set-option -a terminal-features 'screen-256color:RGB'

      # Reduce escape time for better compatibilty with nvim
      set-option -sg escape-time 10
    '';

    programs.neovim = {
      enable = true;
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
