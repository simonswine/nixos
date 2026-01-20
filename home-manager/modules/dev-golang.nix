{
  config,
  lib,
  pkgs,
  ...
}:

with lib;
let
  cfg = config.simonswine.dev.golang;
in
{
  options.simonswine.dev.golang = {
    enable = mkEnableOption "simonswine golang development config";

    package = mkOption {
      type = types.package;
      default = pkgs.go_1_24;
      defaultText = literalExpression "pkgs.go_1_20";
      description = ''
        Which package to use for Go.
      '';
    };

    delvePackage = mkOption {
      type = types.package;
      default = pkgs.delve;
      defaultText = literalExpression "pkgs.delve";
      description = ''
        Which package to use for delve.
      '';
    };

  };

  config = mkIf cfg.enable (mkMerge [
    {
      # install core golang dev packages
      home.packages = with pkgs; [
        cfg.delvePackage
        go-junit-report
        cfg.package
        golangci-lint
        gopls
        gotags
        gotestsum
        modularise
        benchstat
        gopatch
        gotests
        iferr
        gotestsum
        impl
        mockgen
        gotools # for goimports
      ];

      programs.nixvim.plugins = {
        neotest.adapters.golang = {
          enable = true;
          package = pkgs.vimUtils.buildVimPlugin rec {
            pname = "neotest-golang";
            version = "1.15.1";
            src = pkgs.fetchFromGitHub {
              owner = "fredrikaverpil";
              repo = "neotest-golang";
              rev = "v${version}";
              hash = "sha256-fAnd4PFlrDjSmdtH/FwVxlUjKqAkXADh6u2QbgcBBs8=";
            };
            dependencies = with pkgs.vimPlugins; [
              neotest
              nvim-nio
              nvim-dap-go
              nvim-treesitter
              plenary-nvim
            ];
          };
        };
        dap-go = {
          enable = true;
          settings = {
            dap_configurations = [
              {
                type = "go";
                name = "Attach remote";
                mode = "remote";
                request = "attach";
              }
            ];
            delve = {
              path = "dlv";
            };
          };
        };
      };

      simonswine.neovim = {
        lspconfig.gopls = {
          cmd = [
            "${pkgs.gopls}/bin/gopls"
          ];
          gopls = {
            # general settings
            # https://github.com/golang/tools/blob/master/gopls/doc/settings.md
            gofumpt = true;
            analyses = {
              # analyzers settings
              # https://github.com/golang/tools/blob/master/gopls/doc/analyzers.md
              fieldalignment = true;
              nilness = true;
              shadow = true;
              unusedparams = true;
              unusedwrite = true;
              useany = true;
              unusedvariable = true;
            };
            # use linters from staticcheck.io
            staticcheck = true;
            # diagnostics reported by the gc_details command
            annotations = {
              bounds = true;
              escape = true;
              inline = true;
              nil = true;
            };
            hints = {
              # inlayhints settings
              # https://github.com/golang/tools/blob/master/gopls/doc/inlayHints.md
              assignVariableTypes = true;
              compositeLiteralFields = true;
              compositeLiteralTypes = true;
              constantValues = true;
              functionTypeParameters = true;
              parameterNames = true;
              rangeVariableTypes = true;
            };
          };
        };
        lspconfig.golangci_lint_ls.cmd = [
          "${pkgs.golangci-lint-langserver}/bin/golangci-lint-langserver"
        ];
        plugins = with pkgs.vimPlugins; [
          nvim-dap-go
        ];
        extraLuaConfig = ''
          require('dap-go').setup()
        '';
        conformConfig = {
          formatters_by_ft = {
            go = [
              "gofmt"
              "goimports"
            ];
          };
        };
      };
    }
  ]);
}
