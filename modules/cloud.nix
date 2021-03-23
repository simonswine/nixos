{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.cloud;
in
{
  options.cloud = with lib.types; {
    provider = mkOption {
      default = null;
      type = types.enum [ null "hcloud" "scaleway" ];
    };
  };

  config = mkMerge [
    (mkIf (cfg.provider == "hcloud") {
      boot.loader.grub.devices = [ "/dev/disk/by-id/scsi-0QEMU_QEMU_HARDDISK_drive-scsi0-0-0-0" ];
    })
    (mkIf (cfg.provider == "scaleway") {
      boot.loader.grub.efiSupport = true;
      boot.loader.grub.devices = [ "nodev" ];
      boot.loader.grub.efiInstallAsRemovable = true;

      # Enable serial console
      boot.kernelParams = [
        "console=ttyS0,115200"
        "scaleway"
      ];

      # devices on Scaleway can't use the ID
      boot.zfs.devNodes = "/dev";
    })
    (mkIf (cfg.provider != null) {
      # Use the GRUB 2 boot loader.
      boot.loader.grub.enable = true;
      boot.loader.grub.version = 2;

      # The global useDHCP flag is deprecated, therefore explicitly set to false here.
      # Per-interface useDHCP will be mandatory in the future, so this generated config
      # replicates the default behaviour.
      networking.useDHCP = false;
      networking.interfaces.eth0.useDHCP = true;

      # take hostname from DHCP
      networking.hostName = "";

      # This seems to be the stabler choice
      networking.usePredictableInterfaceNames = false;

      services.cloud-init.enable = true;
      services.cloud-init.config = ''
        # logging config from ubuntu 20.04
        _log:
         - &log_base |
           [loggers]
           keys=root,cloudinit

           [handlers]
           keys=consoleHandler,cloudLogHandler

           [formatters]
           keys=simpleFormatter,arg0Formatter

           [logger_root]
           level=DEBUG
           handlers=consoleHandler,cloudLogHandler

           [logger_cloudinit]
           level=DEBUG
           qualname=cloudinit
           handlers=
           propagate=1

           [handler_consoleHandler]
           class=StreamHandler
           level=WARNING
           formatter=arg0Formatter
           args=(sys.stderr,)

           [formatter_arg0Formatter]
           format=%(asctime)s - %(filename)s[%(levelname)s]: %(message)s

           [formatter_simpleFormatter]
           format=[CLOUDINIT] %(filename)s[%(levelname)s]: %(message)s
         - &log_file |
           [handler_cloudLogHandler]
           class=FileHandler
           level=DEBUG
           formatter=arg0Formatter
           args=('/var/log/cloud-init.log', 'a', 'UTF-8')
         - &log_syslog |
           [handler_cloudLogHandler]
           class=handlers.SysLogHandler
           level=DEBUG
           formatter=simpleFormatter
           args=("/dev/log", handlers.SysLogHandler.LOG_USER)

        log_cfgs:
         - [ *log_base, *log_file ]

        output: {all: '| tee -a /var/log/cloud-init-output.log'}

        system_info:
          distro: nixos
        users:
          - root
        disable_root: false
        preserve_hostname: false
        cloud_init_modules:
          - migrator
          - seed_random
          - bootcmd
          - write-files
          - growpart
          - resizefs
          - ca-certs
          - rsyslog
          - users-groups
        cloud_config_modules:
          - disk_setup
          - mounts
          - ssh-import-id
          - set-passwords
          - timezone
          - disable-ec2-metadata
          - runcmd
          - ssh
        cloud_final_modules:
          - rightscale_userdata
          - scripts-vendor
          - scripts-per-once
          - scripts-per-boot
          - scripts-per-instance
          - scripts-user
          - ssh-authkey-fingerprints
          - keys-to-console
          - phone-home
          - final-message
          - power-state-change
        datasource_list:
      '' +
      # configure cloud provider datasource if supported
      (if cfg.provider == "hcloud" then
        ''
          - Hetzner
        '' else if cfg.provider == "scaleway" then
        ''
          - Scaleway
        ''
      else "") +
      ''
        - None
      '';

    })
  ];
}
