{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.simonswine.neovim;
in
{

  config = mkIf cfg.enable
    {

      programs.nixvim = {
        extraPlugins =
          let
            parrot-nvim = pkgs.vimUtils.buildVimPlugin rec {
              pname = "parrot.nvim";
              version = "2.5.1";
              src = pkgs.fetchFromGitHub {
                owner = "frankroeder";
                repo = "parrot.nvim";
                rev = "v${version}";
                hash = "sha256-qzxZISF0vI4ciiBVLsU3Xw2DSPNCuXZIhF8+dtW9FOg=";
              };
              dependencies = [ pkgs.vimPlugins.plenary-nvim ];
              checkInputs = [
                pkgs.curl
                pkgs.ripgrep
                # Optional integrations
                pkgs.vimPlugins.blink-cmp
                pkgs.vimPlugins.nvim-cmp
              ];
            };
          in
          [
            parrot-nvim
          ];

        extraConfigLua = ''
            require("parrot").setup {
          	  providers = {
          		anthropic = {
          		  name = "anthropic",
          		  endpoint = "https://api.anthropic.com/v1/messages",
          		  model_endpoint = "https://api.anthropic.com/v1/models",
          		  api_key = {"gopass", "show", "--nosync", "grafana/console.anthropic.com", "api_key"},
          		  params = {
          			chat = { max_tokens = 4096 },
          			command = { max_tokens = 4096 },
          		  },
          		  topic = {
          			model = "claude-3-5-haiku-latest",
          			params = { max_tokens = 32 },
          		  },
          		  headers = function(self)
          			return {
          			  ["Content-Type"] = "application/json",
          			  ["x-api-key"] = self.api_key,
          			  ["anthropic-version"] = "2023-06-01",
          			}
          		  end,
          		  models = {
          			"claude-sonnet-4-20250514",
          			"claude-3-7-sonnet-20250219",
          			"claude-3-5-sonnet-20241022",
          			"claude-3-5-haiku-20241022",
          		  },
          		  preprocess_payload = function(payload)
          			for _, message in ipairs(payload.messages) do
          			  message.content = message.content:gsub("^%s*(.-)%s*$", "%1")
          			end
          			if payload.messages[1] and payload.messages[1].role == "system" then
          			  -- remove the first message that serves as the system prompt as anthropic
          			  -- expects the system prompt to be part of the API call body and not the messages
          			  payload.system = payload.messages[1].content
          			  table.remove(payload.messages, 1)
          			end
          			return payload
          		  end,
          		},
          	  }
            }
        '';

      };

    };
}
