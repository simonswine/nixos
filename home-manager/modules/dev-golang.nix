{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.simonswine.dev.golang;
in
{
  options.simonswine.dev.golang = {
    enable = mkEnableOption "simonswine golang development config";

    package = mkOption {
      type = types.package;
      default = pkgs.go_1_18;
      defaultText = literalExpression "pkgs.go_1_17";
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

  config = mkIf cfg.enable
    {
      home.sessionVariables = {
        GOROOT = "${cfg.package}/share/go";
      };

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
      ];
      simonswine.neovim = {
        extraConfig = ''
          let g:go_gopls_options = ['-remote=unix;/run/user/' + expand('$UID') + '/gopls-daemon-socket', '-logfile=auto', '-debug=:0', '-rpc.trace']
        '';
        plugins = with pkgs.vimPlugins; [
          vim-go
        ];
      };
      systemd.user.services.gopls = {
        Unit = {
          Description = "Run the go language server as user daemon, so we can limit its memory and CPU usage";
          After = [ "network.target" ];
        };

        Service = {
          Type = "simple";
          Environment = [ "PATH=/run/wrappers/bin:/home/${config.home.username}/.nix-profile/bin:/etc/profiles/per-user/${config.home.username}/bin:/nix/var/nix/profiles/default/bin:/run/current-system/sw/bin" ];
          ExecStartPre = "/run/current-system/sw/bin/rm -f %t/gopls-daemon-socket";
          ExecStart = "${pkgs.gopls}/bin/gopls -listen=\"unix;%t/gopls-daemon-socket\" -logfile=auto -debug=:0";
          Restart = "always";
          MemoryLimit = "6G";
          IOSchedulingClass = "3";
          OOMScoreAdjust = "500";
          CPUSchedulingPolicy = "idle";
        };

        Install = {
          WantedBy = [ "basic.target" ];
        };
      };
    };
}
