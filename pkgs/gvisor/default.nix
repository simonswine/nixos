{
  lib,
  nixosTests,
  buildGo127Module,
  fetchFromGitHub,
  iproute2,
  iptables,
  makeWrapper,
  procps,
  glibc,
}:

buildGo127Module {
  pname = "gvisor";
  version = "20261019.0";

  # gvisor provides a synthetic go branch (https://github.com/google/gvisor/tree/go)
  # that can be used to build gvisor without bazel.
  # For updates, you should stick to the commits labeled "Merge release-** (automated)"

  src = fetchFromGitHub {
    owner = "google";
    repo = "gvisor";
    # Generated Go tree for release-20261019.0 (760b80785).
    rev = "02a34e56a43873ddd1ff5efdda37f63af1b6e7cc";
    hash = "sha256-UNQjk9tJAbyxmf/RFNlIJmhjVT9tEI8uv7/GFVkATKA=";
  };

  # Replace the placeholder with the actual path to ldconfig
  postPatch = ''
    substituteInPlace runsc/container/container.go \
      --replace-fail '"/sbin/ldconfig"' '"${glibc}/bin/ldconfig"'
  '';

  vendorHash = "sha256-LUWROfODg/Ar6LSRGWRvobl1THW+Qa4xerlsCveyEK8=";

  nativeBuildInputs = [ makeWrapper ];

  env.CGO_ENABLED = 0;

  ldflags = [
    "-s"
    "-w"
  ];

  subPackages = [
    "runsc"
    "shim"
    "runsc/cmd/sentry"
    "runsc/cmd/metricserver"
    "runsc/checkpointgofer"
  ];

  postBuild = ''
    # These helpers use raw syscalls and supply their own entry points.
    for helper in prewarmer fdparking procumounter; do
      $CC -O2 -static -nostdlib -fno-stack-protector -fno-builtin \
        -o "$helper" "runsc/$helper/$helper.c"
    done
  '';

  postInstall = ''
    # Since this release, runsc expects its sidecars beside the main binary.
    mkdir -p $out/bin/gvisor-bin
    mv $out/bin/sentry $out/bin/gvisor-bin/gvisor_sentry
    mv $out/bin/metricserver $out/bin/gvisor-bin/runsc-metric-server
    mv $out/bin/checkpointgofer $out/bin/gvisor-bin/checkpointgofer
    install -m755 prewarmer $out/bin/gvisor-bin/gvisor-sentry-prewarmer
    install -m755 fdparking $out/bin/gvisor-bin/runsc-fd-parking
    install -m755 procumounter $out/bin/gvisor-bin/gvisor-proc-umounter

    # Needed for the 'runsc do' subcommand
    wrapProgram $out/bin/runsc \
      --prefix PATH : ${
        lib.makeBinPath [
          iproute2
          iptables
          procps
        ]
      }
    mv $out/bin/shim $out/bin/containerd-shim-runsc-v1
  '';

  patches = [ ./fix-go-mod-tidy.patch ];

  passthru.tests = { inherit (nixosTests) gvisor; };

  meta = {
    description = "Application Kernel for Containers";
    homepage = "https://github.com/google/gvisor";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ gpl ];
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
  };
}
