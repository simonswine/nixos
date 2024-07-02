self: super: {
  containerd = super.containerd.overrideAttrs (old: rec {
    version = "1.7.18";
    commit = "ae71819c4f5e67bb4d5ae76a6b735f29cc25774e";
    src = super.fetchFromGitHub rec {
      owner = "containerd";
      repo = "containerd";
      rev = "v${version}";
      hash = "sha256-IlK5IwniaBhqMgxQzV8btQcbdJkNEQeUMoh6aOsBOHQ=";
    };
    buildPhase = ''
      runHook preBuild
      patchShebangs .
      make binaries "VERSION=v${version}" "REVISION=${src.rev}"
      runHook postBuild
    '';
  });
}
