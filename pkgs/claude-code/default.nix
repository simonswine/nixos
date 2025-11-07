{ lib
, buildNpmPackage
, fetchzip
, writableTmpDirAsHomeHook
, versionCheckHook
, patchelf
,
}:
buildNpmPackage (finalAttrs: {
  pname = "claude-code";
  version = "2.0.31";

  src = fetchzip {
    url = "https://registry.npmjs.org/@anthropic-ai/claude-code/-/claude-code-${finalAttrs.version}.tgz";
    hash = "sha256-KQRc9h2DG1bwWvMR1EnMWi9qygPF0Fsr97+TyKef3NI=";
  };

  npmDepsHash = "sha256-lv596UikbuAuiJ1Wl5xMJvSNITfGOnDvI1dLtaJagCY=";

  postPatch = ''
    cp ${./package-lock.json} package-lock.json
  '';

  nativeBuildInputs = [ patchelf ];

  dontNpmBuild = true;

  env.AUTHORIZED = "1";

  # `claude-code` tries to auto-update by default, this disables that functionality.
  # https://docs.anthropic.com/en/docs/agents-and-tools/claude-code/overview#environment-variables
  # The DEV=true env var causes claude to crash with `TypeError: window.WebSocket is not a constructor`
  postInstall = ''
    wrapProgram $out/bin/claude \
      --set DISABLE_AUTOUPDATER 1 \
      --unset DEV
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [
    writableTmpDirAsHomeHook
  ];

  passthru.updateScript = ./update.sh;

  meta = {
    description = "Agentic coding tool that lives in your terminal, understands your codebase, and helps you code faster";
    homepage = "https://github.com/anthropics/claude-code";
    downloadPage = "https://www.npmjs.com/package/@anthropic-ai/claude-code";
    # TODO: license = lib.licenses.unfree;
    maintainers = with lib.maintainers; [
      malo
      markus1189
      omarjatoi
      xiaoxiangmoe
    ];
    mainProgram = "claude";
  };
})
