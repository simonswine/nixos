{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.simonswine.neovim;

  copilot-git = pkgs.vimUtils.buildVimPlugin rec {
    name = "copilot.vim";
    version = "1.26.0";
    src = pkgs.fetchFromGitHub {
      owner = "github";
      repo = "copilot.vim";
      rev = "v${version}";
      hash = "sha256-tcLrto1Y66MtPnfIcU2PBOxqE0xilVl4JyKU6ddS7bA=";
    };
  };
in
{
  options.simonswine.neovim = {
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
    programs.neovim = {
      enable = true;
      viAlias = true;
      vimAlias = true;
      vimdiffAlias = true;

      plugins = (with pkgs.vimPlugins; [
        vim-colors-solarized
        vim-airline
        nerdtree

        copilot-git


        pkgs.vim-markdown-composer

        ack-vim

        coq_nvim
        nvim-lspconfig

        fzf-vim
        vista-vim

        # git support for vim
        vim-fugitive
        vim-rhubarb

        (pkgs.vimPlugins.nvim-treesitter.withPlugins (plugins: with pkgs.tree-sitter-grammars; [
          tree-sitter-beancount
          tree-sitter-c
          tree-sitter-dockerfile
          tree-sitter-gomod
          tree-sitter-html
          tree-sitter-json
          tree-sitter-make
          tree-sitter-markdown
          tree-sitter-nix
          tree-sitter-yaml
        ]
        ))
        nvim-treesitter-context

      ]) ++ cfg.plugins;

      extraConfig =
        let
          lsp_servers_config = builtins.concatStringsSep "\n" (
            attrValues (mapAttrs
              (name: cmd:
                ''\ '${name}': ['${(builtins.concatStringsSep "', '" cmd)}'],''
              )
              cfg.lsp_servers));
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

          " Show whitespaces type
          set list
          set listchars=tab:>.,trail:.,extends:#,nbsp:.

          " fix background color erase
          let g:solarized_termtrans=1

          " Set the colorscheme
          set background=dark
          colorscheme solarized

          "" vim-airline settings
          set laststatus=2
          let g:airline_powerline_fonts = 1
          let g:airline_detect_paste=1

          " Vista
          let g:vista_ctags_executable = '${pkgs.universal-ctags}/bin/ctags'
          let g:vista_fzf_preview = ['right:50%']
          let g:vista_icon_indent = ["╰─▸ ", "├─▸ "]

          " Copilot
          let g:copilot_filetypes = {
             \ '*': v:false,
             \ 'go': v:true,
             \ 'jsonnet': v:true,
             \ 'json': v:true,
             \ 'yaml': v:true,
             \ 'python': v:true,
             \ 'nix': v:true,
             \ }

          " Setup correct path to ag
          let g:ackprg = '${pkgs.silver-searcher}/bin/ag --vimgrep'

          lua << EOF
          local treesitter = require "nvim-treesitter.configs"
          local lspconfig = require('lspconfig')
          local coq = require('coq')

          -- Setup language servers.
          lspconfig.beancount.setup(coq.lsp_ensure_capabilities({
            cmd = { '${pkgs.beancount-language-server}/bin/beancount-language-server', '--stdio' },
          }))
          lspconfig.gopls.setup(coq.lsp_ensure_capabilities({
            cmd = { '${pkgs.gopls}/bin/gopls' },
          }))
          lspconfig.pylsp.setup(coq.lsp_ensure_capabilities({
            cmd = { '${pkgs.python3Packages.python-lsp-server}/bin/pylsp' },
          }))
          lspconfig.rust_analyzer.setup(coq.lsp_ensure_capabilities({
            cmd = { '${pkgs.rust-analyzer}/bin/rust-analyzer' },
          }))
          lspconfig.jsonnet_ls.setup(coq.lsp_ensure_capabilities({
            cmd = { '${pkgs.jsonnet-language-server}/bin/jsonnet-language-server' },
          }))
          lspconfig.clangd.setup(coq.lsp_ensure_capabilities({
            cmd = { '${pkgs.clang-tools}/bin/clangd' },
          }))
          lspconfig.tsserver.setup(coq.lsp_ensure_capabilities({
            cmd = { '${pkgs.nodePackages.typescript-language-server}/bin/typescript-language-server', '--stdio' },
          }))


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
              vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, opts)
              vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, opts)
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

          treesitter.setup {
            highlight = {
              enable = true,
              disable = {},
            },
            indent = {
              enable = true,
              disable = {},
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
