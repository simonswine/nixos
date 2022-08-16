{ lib
, rustPlatform
, pkgs
}:

let
  bin = rustPlatform.buildRustPackage {
    pname = pkgs.vimPlugins.vim-markdown-composer.name + "-bin";
    version = pkgs.vimPlugins.vim-markdown-composer.version;
    src = pkgs.vimPlugins.vim-markdown-composer.src;
    cargoSha256 = "hGhOAY2XyHDro6e/OHbC9o8HLwWyCI2imYSXy2ORwM0=";
  };
in

pkgs.vimUtils.buildVimPlugin {
  name = pkgs.vimPlugins.vim-markdown-composer.name;
  src = pkgs.vimPlugins.vim-markdown-composer.src;

  preInstall = ''
    mkdir -p vim-plugin/ftplugin/markdown vim-plugin/config
    cp after/ftplugin/markdown/composer.vim vim-plugin/ftplugin/markdown/composer.vim
    cp config/log.yaml vim-plugin/config/log.yaml
    cd vim-plugin
  '';

  preFixup = ''
    substituteInPlace "$out"/ftplugin/markdown/composer.vim \
      --replace "let s:plugin_root = expand('<sfile>:p:h:h:h:h')" "let s:plugin_root = expand('<sfile>:p:h:h:h')"
  '';

  postFixup = ''
    mkdir -p $target/target/
    ln -s ${bin}/bin/ $target/target/release
  '';
}


