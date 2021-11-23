{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.iptables-restore;
in
{
  meta.maintainers = [ maintainers.simonswine ];

  options.services.iptables-restore = {
    enable = mkEnableOption "iptables-restore";

    rulesV4 = mkOption {
      default = "";
      type = types.str;
    };

    rulesV6 = mkOption {
      default = "";
      type = types.str;
    };

  };

  config = mkIf cfg.enable {
    environment.etc = {
      "iptables/iptables.rules".text = cfg.rulesV4;
      "iptables/ip6tables.rules".text = cfg.rulesV6;
    };

    systemd.services =
      let
        iptablesFlush = pkgs.writeScript "iptables-flush" ''
          #!${pkgs.bash}/bin/bash
          #
          # Usage: iptables-flush [6]
          #

          iptables=ip$1tables
          if ! type -p "$iptables" &>/dev/null; then
            echo "error: invalid argument"
            exit 1
          fi

          while read -r table; do
            # TODO: package those tables
            tables+=("/usr/share/iptables/empty-$table.rules")
          done <"/proc/net/ip$1_tables_names"

          if (( $${#tables[*]} )); then
            cat "$${tables[@]}" | "$iptables-restore"
          fi
        '';
      in
      {
        iptables-restore = {
          description = "IPv4 Packet Filtering Framework";
          before = [ "network-pre.target" ];
          wants = [ "network-pre.target" ];
          wantedBy = [ "multi-user.target" ];

          serviceConfig = {
            Type = "oneshot";
            ExecStart = "${pkgs.iptables}/bin/iptables-restore /etc/iptables/iptables.rules";
            ExecReload = "${pkgs.iptables}/bin/iptables-restore /etc/iptables/iptables.rules";
            #ExecStop = iptablesFlush;
            RemainAfterExit = true;
          };
        };
        ip6tables-restore = {
          description = "IPv6 Packet Filtering Framework";
          before = [ "network-pre.target" ];
          wants = [ "network-pre.target" ];
          wantedBy = [ "multi-user.target" ];
          # this avoids a race for the lock
          after = [ "iptables-restore.service" ];

          serviceConfig = {
            Type = "oneshot";
            ExecStart = "${pkgs.iptables}/bin/ip6tables-restore /etc/iptables/ip6tables.rules";
            ExecReload = "${pkgs.iptables}/bin/ip6tables-restore /etc/iptables/ip6tables.rules";
            #ExecStop = "${iptablesFlush} 6";
            RemainAfterExit = true;
          };
        };
      };
  };
}
