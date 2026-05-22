{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPackages,
  makeSetupHook,
  binutils,
  xxd,
  strace,
}:

let
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "Mic92";
    repo = "wrap-buddy";
    rev = "v${version}";
    hash = "sha256-kZfaqMDKV0zyw8OP2HWJgGEHnbIXPUz2yI6Yl9MlilU=";
  };

  dynamicLinker = stdenv.cc.bintools.dynamicLinker;

  libcLib = "${stdenv.cc.libc}/lib";

  cxxForBuild = "${buildPackages.stdenv.cc}/bin/c++";

  wrapBuddy = stdenv.mkDerivation {
    pname = "wrap-buddy";
    inherit version src;

    depsBuildBuild = [
      buildPackages.stdenv.cc
    ];

    nativeBuildInputs = [
      binutils
      xxd
    ];

    makeFlags = [
      "CXX_FOR_BUILD=${cxxForBuild}"
      "BINDIR=$(out)/bin"
      "LIBDIR=$(out)/lib/wrap-buddy"
      "INTERP=${dynamicLinker}"
      "LIBC_LIB=${libcLib}"
    ]
    ++ lib.optional stdenv.hostPlatform.isx86_64 "BUILD_32BIT=1";

    nativeInstallCheckInputs = [ strace ];
    doInstallCheck = true;
    installCheckTarget = "check";
    enableParallelBuilding = true;

    meta = {
      description = "Patch ELF binaries with stub loader for NixOS compatibility";
      homepage = "https://github.com/Mic92/wrap-buddy";
      mainProgram = "wrap-buddy";
      license = lib.licenses.mit;
      platforms = [
        "x86_64-linux"
        "i686-linux"
        "aarch64-linux"
      ];
    };
  };

  hook = makeSetupHook {
    name = "wrap-buddy-hook";
    propagatedBuildInputs = [ wrapBuddy ];
    passthru.hideFromDocs = true;
    meta = {
      description = "Setup hook that patches ELF binaries with stub loader";
      license = lib.licenses.mit;
      platforms = lib.platforms.linux;
    };
  } "${src}/nix/wrap-buddy-hook.sh";
in
hook
