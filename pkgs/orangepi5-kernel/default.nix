{
  linuxManualConfig,
  fetchFromGitHub,
  ubootTools,
  ...
}:
(linuxManualConfig {
  src = fetchFromGitHub {
    owner = "simonswine";
    repo = "linux-rockchip";
    # Note this is a fork of armbian
    # NVMe fixes (backported from upstream stable, so the NVMe gets detected, echo 1 > /sys/class/nvme/nvme0/rescan_controller' if not detected):
    # - Disable CC.CRIME (42dba1f4) — Disables NVME_CC_CRIME so that CSTS.RDY correctly signals media readiness, preventing NVME_SC_ADMIN_COMMAND_MEDIA_NOT_READY errors.
    # - Synchronous keep-alive (c44771bf) — Fixes a kernel crash race condition between keep-alive work and fabric controller shutdown/admin queue teardown.
    # - Defer partition scanning in multipath (48c7d242) — Avoids a deadlock when a path error occurs during partition scanning within scan_work context.
    # Security fixes:
    # - ESP/xfrm shared skb frag fix (81187a02) — Prevents in-place decryption over shared pipe-backed skb frags in ESP-in-UDP, which could corrupt data not privately owned by the skb.
    rev = "42dba1f4966f8be7689ebbd7d49f5402dc432616";
    hash = "sha256-VwZaMrOFIiU7w5ThRzdFIBLcSG9MSgY3DY4sxcuYMS8=";
  };
  version = "6.1.115";
  modDirVersion = "6.1.115";
  extraMeta.branch = "6.1";
  # this is from https://raw.githubusercontent.com/Joshua-Riek/linux-rockchip/ffa29fd4b815ff04b78e9f850ac42c6b7011ad17/debian.rockchip/config/config.common.ubuntu
  # then a docker container is used to make oldconfig
  # with modules
  # aes aes_generic blowfish twofish serpent cbc xts lrw sha1 sha256 sha512 af_alg algif_skcipher xts ecb
  # dm_mod dm_crypt cryptd input_leds
  # $ docker run -t -i -v $(pwd):/app --workdir /app debian
  # $ apt-get update && apt-get -y install build-essential bc kmod cpio flex libncurses5-dev libelf-dev libssl-dev dwarves bison git vim
  configfile = ./config;
  allowImportFromDerivation = true;
}).overrideAttrs
  (
    finalAttrs: previousAttrs: {
      nativeBuildInputs = previousAttrs.nativeBuildInputs ++ [
        ubootTools
      ];
    }
  )
