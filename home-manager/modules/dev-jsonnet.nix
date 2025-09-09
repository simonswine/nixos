{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.simonswine.dev.jsonnet;
in
{
  options.simonswine.dev.jsonnet = {
    enable = mkEnableOption "simonswine jsonnet development config";
  };

  config = mkIf cfg.enable
    {
      home.packages = with pkgs; [
        jsonnet
        jsonnet-bundler
        tanka
        nodePackages.js-yaml
      ];
      programs.nixvim.extraConfigLua = ''
        -- Function to evaluate jsonnet files
        local function jsonnet_eval()
          local current_file = vim.fn.expand('%')
          local escaped_file = vim.fn.shellescape(current_file)
  
          -- Check if it's a tanka file
          local jpath_cmd = "tk tool jpath " .. escaped_file
          local jpath_output = vim.fn.system(jpath_cmd)
          local shell_error = vim.v.shell_error
  
          local output
          if shell_error ~= 0 then
            -- Not a tanka file, use jsonnet
            output = vim.fn.system("jsonnet " .. escaped_file)
          else
            -- Is a tanka file, use tk eval
            output = vim.fn.system("tk eval " .. escaped_file)
          end
  
          -- Create new vertical split
          vim.cmd('vnew')
  
          -- Set buffer options
          vim.bo.buflisted = false
          vim.bo.buftype = 'nofile'
          vim.bo.bufhidden = 'wipe'
          vim.bo.swapfile = false
          vim.bo.filetype = 'json'
  
          -- Insert output at the beginning of buffer
          vim.fn.append(0, vim.split(output, '\n'))
  
          -- Remove the empty line at the end
          vim.cmd('$delete')
        end

        -- Create autocommand for jsonnet filetype
        vim.api.nvim_create_autocmd("FileType", {
          pattern = "jsonnet",
          callback = function()
            vim.keymap.set('n', '<leader>b', jsonnet_eval, {
              buffer = true,
              desc = "Evaluate jsonnet file"
            })
          end,
        })'';

      simonswine.neovim = {
        lspconfig.jsonnet_ls = {
          cmd = [
            "${pkgs.jsonnet-language-server}/bin/jsonnet-language-server"
          ];
          filetypes = [
            "jsonnet"
          ];
        };
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
