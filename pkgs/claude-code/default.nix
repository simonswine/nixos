{
  writeShellScriptBin,
  claude-code-unwrapped,
}:

(writeShellScriptBin "claude" ''
  export CLAUDE_CODE_DISABLE_FEEDBACK_SURVEY=1
  export CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC=1
  export IS_DEMO=1

  case "$1" in
    auth|auto-mode|daemon|doctor|gateway|install|mcp|plugin|plugins|project|setup-token|update|--help|--version)
      exec ${claude-code-unwrapped}/bin/claude "$@"
      ;;
  esac

  if [ -n "$CLAUDE_SETTINGS_SOURCES" ]; then
    for arg in "$@"; do
      case "$arg" in
        --setting-sources|--setting-sources=*)
          exec ${claude-code-unwrapped}/bin/claude "$@"
          ;;
      esac
    done

    # Project MCP configuration is unaffected.
    exec ${claude-code-unwrapped}/bin/claude --setting-sources "$CLAUDE_SETTINGS_SOURCES" "$@"
  fi

  exec ${claude-code-unwrapped}/bin/claude "$@"
'').overrideAttrs (_: {
  pname = "claude-code";
  inherit (claude-code-unwrapped) version meta;
})
