{ linuxManualConfig
, fetchFromGitHub
, ubootTools
, ...
}: (linuxManualConfig {
  src = fetchFromGitHub {
    owner = "armbian";
    repo = "linux-rockchip";
    rev = "cd13061a07d985e883fae4e0a597fd9bdc112817";
    hash = "sha256-y8D3lnbu4mQ5237kdAI6jciQLmEGIZUH4qQKWZlgQ48=";
  };
  version = "6.1.84";
  modDirVersion = "6.1.84";
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
  (finalAttrs: previousAttrs: {
    nativeBuildInputs = previousAttrs.nativeBuildInputs ++ [
      ubootTools
    ];
  })
