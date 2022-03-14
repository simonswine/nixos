{ stdenv, lib, linuxKernel }:

stdenv.mkDerivation {
  pname = "rpi-device-tree-overlay";
  inherit (linuxKernel.kernels.linux_rpi4) version src;

  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/dts/overlays
    for f in arch/arm/boot/dts/overlays/*.dts; do
      cpp -nostdinc -I include -I arch  -undef -x assembler-with-cpp $f $out/share/dts/overlays/$(basename $f)
      sed -i 's#"brcm,bcm2835"#"brcm,bcm2711"#g' $out/share/dts/overlays/$(basename $f)
    done

    runHook postInstall
  '';
}

