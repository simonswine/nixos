{
  stdenv,
  fetchFromGitHub,
  hidapi,
}:

# adapted from https://github.com/wiltaylor/dotfiles/blob/c5aa0ac46448938796ba85c53e5240f8d832219d/pkgs/default.nix#L25

stdenv.mkDerivation rec {
  pname = "g810-led";
  version = "0.4.3";

  src = fetchFromGitHub {
    owner = "Digicrat";
    repo = "g810-led";
    rev = "v${version}";
    sha256 = "GKHtQ7DinqfhclDdPO94KtTLQhhonAoWS4VOvs6CMhY=";
  };

  buildInputs = [ hidapi ];

  patches = [
    ./0001-OSX-Makefile-changes.patch
  ];

  buildPhase = ''
    sed -i "s#/usr/bin/#$out/bin/#g" udev/g810-led.rules
    sed -i "s#/usr/bin/#$out/bin/#g" systemd/g810-led.service
    sed -i "s#/usr/bin/#$out/bin/#g" systemd/g810-led-reboot.service
    sed -i "s#/etc/g810-led/profile#$out/etc/g810-led/samples/group_keys#g" systemd/g810-led.service
    sed -i "s#/etc/g810-led/reboot#$out/etc/g810-led/samples/all_off#g" systemd/g810-led-reboot.service
    make bin
  '';

  installPhase = ''
    mkdir -p $out -p
    mkdir -p $out/etc/g810-led/samples
    mkdir -p $out/lib/systemd/system
    mkdir -p $out/lib/udev/rules.d
    cp -R bin $out
    cp udev/g810-led.rules $out/lib/udev/rules.d/g810-led.rules
    cp systemd/* $out/lib/systemd/system
    ln -s $out/bin/g810-led $out/bin/g213-led
    ln -s $out/bin/g810-led $out/bin/g410-led
    ln -s $out/bin/g810-led $out/bin/g413-led
    ln -s $out/bin/g810-led $out/bin/g512-led
    ln -s $out/bin/g810-led $out/bin/g513-led
    ln -s $out/bin/g810-led $out/bin/g610-led
    ln -s $out/bin/g810-led $out/bin/g815-led
    ln -s $out/bin/g810-led $out/bin/gpro-led
    ln -s $out/bin/g810-led $out/bin/g910-led
    cp sample_profiles/* $out/etc/g810-led/samples
  '';
}
