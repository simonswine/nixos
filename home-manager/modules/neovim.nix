{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.simonswine.neovim;

  copilot-git = pkgs.vimUtils.buildVimPlugin {
    name = "vim-easygrep";
    version = "1.8.0";
    src = pkgs.fetchFromGitHub {
      owner = "github";
      repo = "copilot.vim";
      rev = "324ec9eb69e20971b58340d0096c3caac7bc2089";
      sha256 = "b3c/EQmObPKnT5pBbhAbAySGt2E+1UC0Zqm2vJJiv/4=";
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
        LanguageClient-neovim
        nerdtree

        copilot-git

        pkgs.vim-markdown-composer

        ack-vim

        fzf-vim
        vista-vim

        # git support for vim
        vim-fugitive
        vim-rhubarb

        (pkgs.vimPlugins.nvim-treesitter.withPlugins (plugins: with pkgs.tree-sitter-grammars; [
          tree-sitter-beancount
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

          " Setup correct path to ag
          let g:ackprg = '${pkgs.silver-searcher}/bin/ag --vimgrep'

          lua << EOF
          require'nvim-treesitter.configs'.setup {
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

        '' +
        ''
          " language client config
          nnoremap <silent> gh :call LanguageClient#textDocument_hover()<CR>
          nnoremap <silent> gd :call LanguageClient#textDocument_definition()<CR>
          nnoremap <silent> gr :call LanguageClient#textDocument_references()<CR>
          nnoremap <silent> gs :call LanguageClient#textDocument_documentSymbol()<CR>
          nnoremap <silent> <F2> :call LanguageClient#textDocument_rename()<CR>
          nnoremap <silent> <F3> :call LanguageClient#textDocument_formatting()<CR>

          let g:LanguageClient_serverCommands = {
        '' + lsp_servers_config +
        ''

          \ }

        '' + cfg.extraConfig;
    };
    systemd.user.tmpfiles.rules = [
      "d %h/.vim/backup 0700 - - -"
      "d %h/.vim/swap 0700 - - -"
      "d %h/.vim/undo 0700 - - -"
    ];
  };
}
