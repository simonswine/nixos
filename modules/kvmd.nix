{ config, pkgs, lib, ... }:
let
  cfg = config.services.kvmd;
in
with lib;

{
  options.services.kvmd = {
    enable = mkEnableOption "kvmd";
  };

  config =
    let
      command = "${pkgs.kvmd}/bin/kvmd --font ${cfg.font} --height=32";
    in
    mkIf cfg.enable {

      # According to https://github.com/pikvm/kvmd/blob/2666cf6d56adc418f2f9b528ecc64cfe5122b947/configs/os/sysusers.conf#L1
      # TODO: Define additional group memberships
      ids.uids = {
        kvmd = 450;
        kvmd-ipmi = 451;
        kvmd-vnc = 452;
        kvmd-nginx = 453;
        kvmd-janus = 454;
      };

      ids.gids = {
        kvmd = 450;
        kvmd-ipmi = 451;
        kvmd-vnc = 452;
        kvmd-nginx = 453;
        kvmd-janus = 454;
      };

      users.groups = {
        kvmd.gid = config.ids.gids.kvmd;
        kvmd-ipmi.gid = config.ids.gids.kvmd-ipmi;
        kvmd-vnc.gid = config.ids.gids.kvmd-vnc;
        kvmd-nginx.gid = config.ids.gids.kvmd-nginx;
        kvmd-janus.gid = config.ids.gids.kvmd-janus;
      };

      users.extraUsers =
        {
          kvmd = {
            uid = config.ids.uids.kvmd;
            isNormalUser = false;
            group = "kvmd";
          };
          kvmd-ipmi = {
            uid = config.ids.uids.kvmd-ipmi;
            isNormalUser = false;
            group = "kvmd-ipmi";
          };
          kvmd-vnc = {
            uid = config.ids.uids.kvmd-vnc;
            isNormalUser = false;
            group = "kvmd-vnc";
          };
          kvmd-nginx = {
            uid = config.ids.uids.kvmd-nginx;
            isNormalUser = false;
            group = "kvmd-nginx";
          };
          kvmd-janus = {
            uid = config.ids.uids.kvmd-janus;
            isNormalUser = false;
            group = "kvmd-janus";
          };
        };

      services.udev.extraRules = ''
        # https://unix.stackexchange.com/questions/66901/how-to-bind-usb-device-under-a-static-name
        # https://wiki.archlinux.org/index.php/Udev#Setting_static_device_names
        KERNEL=="video[0-9]*", SUBSYSTEM=="video4linux", KERNELS=="fe801000.csi|fe801000.csi1", ATTR{name}=="unicam-image", GROUP="kvmd", SYMLINK+="kvmd-video", TAG+="systemd"
        KERNEL=="hidg0", GROUP="kvmd", SYMLINK+="kvmd-hid-keyboard"
        KERNEL=="hidg1", GROUP="kvmd", SYMLINK+="kvmd-hid-mouse"
        KERNEL=="hidg2", GROUP="kvmd", SYMLINK+="kvmd-hid-mouse-alt"
        KERNEL=="sd[a-z]", SUBSYSTEM=="block", KERNELS=="1-1.4:1.0", GROUP="kvmd", SYMLINK+="kvmd-msd-aum"
      '';

      environment.etc."kvmd/tc358743-edid.hex".source = "${pkgs.kvmd}/share/configs/kvmd/tc358743-edid.hex";
      environment.etc."kvmd/main.yaml".source = "${pkgs.kvmd}/share/configs/kvmd/main/v3-hdmi-rpi4.yaml";

      systemd.tmpfiles.rules = [
        "D /run/kvmd 0775 kvmd kvmd -"
      ];

      systemd.services.kvmd = {
        description = "Pi-KVM - The main daemon";
        #wantedBy = [ "multi-user.target" ];
        unitConfig = {
          After = [ "network.target" "network-online.target" "nss-lookup.target" ];
        };
        serviceConfig = {
          User = "kvmd";
          Group = "kvmd";
          Type = "simple";
          Restart = "always";
          RestartSec = 3;
          AmbientCapabilities = [ "CAP_NET_RAW" ];
          TimeoutStopSec = 10;
          ExecStartPre = "+${pkgs.writeScript "prepare-kvmd" ''
            #!${pkgs.bash}/bin/bash

            set -euo pipefail

            chmod 0660 /dev/vchiq
            chgrp kvmd /dev/vchiq

            chmod 0660 /dev/gpiochip0
            chgrp kvmd /dev/gpiochip0

            mkdir -p /etc/kvmd/ /etc/kvmd/override.d

            for f in auth.yaml logging.yaml meta.yaml override.yaml  web.css; do
              test -e "/etc/kvmd/$f" || cp "${pkgs.kvmd}/share/configs/kvmd/$f" "/etc/kvmd/$f"
            done

            for f in htpasswd ipmipasswd vncpasswd; do
              test -e "/etc/kvmd/$f" || cp "${pkgs.kvmd}/share/configs/kvmd/$f" "/etc/kvmd/$f"
              chmod 0600 "/etc/kvmd/$f"
            done
            chown kvmd:kvmd /etc/kvmd/htpasswd
            chown kvmd-ipmi:kvmd-ipmi /etc/kvmd/ipmipasswd
            chown kvmd-vnc:kvmd-vnc /etc/kvmd/vncpasswd

            mkdir -p /var/lib/kvmd/msd
            chown kvmd /var/lib/kvmd/msd || true

            if [ ! -e /etc/kvmd/nginx/ssl/server.crt ]; then
              echo "==> Generating KVMD-Nginx certificate ..."
              ${pkgs.kvmd}/bin/kvmd-gencert --do-the-thing
            fi

            if [ ! -e /etc/kvmd/vnc/ssl/server.crt ]; then
              echo "==> Generating KVMD-VNC certificate ..."
              ${pkgs.kvmd}/bin/kvmd-gencert --do-the-thing --vnc
            fi
          ''}";
          ExecStart = "${pkgs.kvmd}/bin/kvmd --run";
          ExecStopPost = "${pkgs.kvmd}/bin/kvmd-cleanup --run";
          KillMode = "mixed";
        };
      };
      systemd.services.kvmd-otg = {
        description = "Pi-KVM - OTG setup";
        wantedBy = [ "multi-user.target" ];
        unitConfig = {
          After = [ "systemd-modules-load.service" ];
          Before = [ "kvmd.service" ];
        };
        serviceConfig = {
          Type = "oneshot";
          ExecStart = "${pkgs.kvmd}/bin/kvmd-otg start";
          ExecStop = "${pkgs.kvmd}/bin/kvmd-otg stop";
          RemainAfterExit = true;
        };
      };
      systemd.services.kvmd-tc358743 = {
        description = "Pi-KVM - EDID loader for TC358743";
        wantedBy = [ "multi-user.target" ];
        unitConfig = {
          After = [ "dev-kvmd\x2dvideo.device" "systemd-modules-load.service" ];
          Before = [ "kvmd.service" ];
          Wants = [ "dev-kvmd\x2dvideo.device" ];
        };
        serviceConfig = {
          Type = "oneshot";
          ExecStart = "${pkgs.v4l-utils}/bin/v4l2-ctl --device=/dev/kvmd-video --set-edid=file=/etc/kvmd/tc358743-edid.hex --fix-edid-checksums --info-edid";
          ExecStop = "/run/current-system/sw/bin/true";
          RemainAfterExit = true;
        };
      };
      systemd.services.kvmd-nginx = {
        description = "Pi-KVM - HTTP entrypoint";
        wantedBy = [ "multi-user.target" ];
        unitConfig = {
          After = [ "network.target" "network-online.target" "nss-lookup.target" "kvmd.service" ];
        };
        serviceConfig = {
          Type = "forking";
          PIDFile = "/run/kvmd/nginx.pid";
          PrivateDevices = true;
          SyslogLevel = "err";
          ExecStart = "${pkgs.nginx}/bin/nginx -p ${pkgs.kvmd}/share/configs/nginx -c ${pkgs.kvmd}/share/configs/nginx/nginx.conf -g 'pid /run/kvmd/nginx.pid; user kvmd-nginx; error_log stderr;'";
          ExecReload = "${pkgs.nginx}/bin/nginx -s reload -p ${pkgs.kvmd}/share/configs/nginx -c ${pkgs.kvmd}/share/configs/nginx/nginx.conf";
          KillSignal = "SIGQUIT";
          KillMode = "mixed";
          TimeoutStopSec = 3;
        };
      };
    };
}
