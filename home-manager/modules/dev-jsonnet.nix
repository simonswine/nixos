{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.simonswine.dev.jsonnet;
in
{
  options.simonswine.dev.jsonnet = {
    enable = mkEnableOption "simonswine jsonnet development config";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      jsonnet
    ];
    simonswine.neovim = {
      lsp_servers.jsonnet = [ "${pkgs.jsonnet-language-server}/bin/jsonnet-language-server" ];
      plugins = with pkgs.vimPlugins; [ vim-jsonnet ];
      extraConfig = ''
        " JSONNET
        au FileType jsonnet nmap <leader>b :call JsonnetEval()<cr>
        function! JsonnetEval()
          " check if the file is a tanka file or not
          let output = system("tk tool jpath " . shellescape(expand('%')))
          if v:shell_error
            let output = system("jsonnet " . shellescape(expand('%')))
          else
            let output = system("tk eval " . shellescape(expand('%')))
          endif
          vnew
          setlocal nobuflisted buftype=nofile bufhidden=wipe noswapfile ft=json
          put! = output
        endfunction
      '';
    };
  };
}
