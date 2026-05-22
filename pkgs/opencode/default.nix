{ pkgs, ... }:
pkgs.callPackage ./package.nix {
  wrapBuddy = pkgs.callPackage ../wrap-buddy { };
  versionCheckHomeHook = pkgs.callPackage ../version-check-home-hook { };
}
