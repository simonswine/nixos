{
  lib,
  stdenvNoCC,
  fetchurl,
  installShellFiles,
  makeBinaryWrapper,
  autoPatchelfHook,
  versionCheckHook,
  writableTmpDirAsHomeHook,
  bubblewrap,
  procps,
  ripgrep,
  runtimeShell,
  socat,
}:
let
  baseUrl = "https://storage.googleapis.com/claude-code-dist-86c565f3-f756-42ad-8dfa-d59b1c096819/claude-code-releases";
  manifest = lib.importJSON ./manifest.json;
  platformKey = "${stdenvNoCC.hostPlatform.node.platform}-${stdenvNoCC.hostPlatform.node.arch}";
  platformManifestEntry = manifest.platforms.${platformKey};
in
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "claude-code";
  inherit (manifest) version;

  src = fetchurl {
    url = "${baseUrl}/${finalAttrs.version}/${platformKey}/claude";
    sha256 = platformManifestEntry.checksum;
  };

  dontUnpack = true;
  dontBuild = true;
  __noChroot = stdenvNoCC.hostPlatform.isDarwin;
  # otherwise the bun runtime is executed instead of the binary
  dontStrip = true;

  nativeBuildInputs = [
    installShellFiles
    makeBinaryWrapper
  ]
  ++ lib.optionals stdenvNoCC.hostPlatform.isElf [ autoPatchelfHook ];

  strictDeps = true;

  installPhase = ''
    runHook preInstall

    installBin $src
    mv $out/bin/claude $out/bin/claude-bin

    wrapProgram $out/bin/claude-bin \
      --set DISABLE_AUTOUPDATER 1 \
      --set-default FORCE_AUTOUPDATE_PLUGINS 1 \
      --set DISABLE_INSTALLATION_CHECKS 1 \
      --set CLAUDE_CODE_DISABLE_FEEDBACK_SURVEY 1 \
      --set CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC 1 \
      --set IS_DEMO 1 \
      --set USE_BUILTIN_RIPGREP 0 \
      --prefix PATH : ${
        lib.makeBinPath (
          [
            procps
            ripgrep
          ]
          # the following packages are required for the sandbox to work (Linux only)
          ++ lib.optionals stdenvNoCC.hostPlatform.isLinux [
            bubblewrap
            socat
          ]
        )
      }

    cat > $out/bin/claude <<EOF
    #!${runtimeShell}

    case "\$1" in
      auth|auto-mode|daemon|doctor|gateway|install|mcp|plugin|plugins|project|setup-token|update|--help|--version)
        exec "$out/bin/claude-bin" "\$@"
        ;;
    esac

    if [ -n "\$CLAUDE_SETTINGS_SOURCES" ]; then
      for arg in "\$@"; do
        case "\$arg" in
          --setting-sources|--setting-sources=*)
            exec "$out/bin/claude-bin" "\$@"
            ;;
        esac
      done

      # Project MCP configuration is unaffected.
      exec "$out/bin/claude-bin" --setting-sources "\$CLAUDE_SETTINGS_SOURCES" "\$@"
    fi

    exec "$out/bin/claude-bin" "\$@"
    EOF
    chmod 755 $out/bin/claude

    runHook postInstall
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [
    writableTmpDirAsHomeHook
    versionCheckHook
  ];
  versionCheckKeepEnvironment = [ "HOME" ];
  versionCheckProgramArg = "--version";

  passthru.updateScript = ./update.sh;

  meta = {
    description = "Agentic coding tool that lives in your terminal, understands your codebase, and helps you code faster";
    homepage = "https://github.com/anthropics/claude-code";
    downloadPage = "https://www.npmjs.com/package/@anthropic-ai/claude-code";
    license = lib.licenses.unfree;
    maintainers = with lib.maintainers; [
      adeci
      malo
      markus1189
      omarjatoi
      oskarwires
      xiaoxiangmoe
    ];
    mainProgram = "claude";
    platforms = [
      "aarch64-darwin"
      "x86_64-darwin"
      "aarch64-linux"
      "x86_64-linux"
    ];
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
  };
})
