{
  lib,
  haskell,
  fetchFromGitHub,
}:
let
  hpkgs = haskell.packages.ghc9103;

  src = fetchFromGitHub {
    owner = "entropia";
    repo = "tip-toi-reveng";
    rev = "1.11";
    hash = "sha256-4IsSghGX8Pc3S2DamOFuDkd+twMBwpE1C3tGS6pBJNM=";
  };

  tttool = haskell.lib.compose.doJailbreak (
    haskell.lib.overrideCabal (hpkgs.callCabal2nix "tttool" src { }) (_: {
      postPatch = ''
        # mtl >= 2.3: MonadFix no longer re-exported from Control.Monad.Writer.Lazy
        sed -i 's/import Control.Monad.Writer.Lazy/import Control.Monad.Fix\nimport Control.Monad.Writer.Lazy/' src/GMEWriter.hs

        # HPDF >= 1.5: PDFFont takes AnyFont (not FontName); author field is Text.
        # Load the embedded Helvetica font once via unsafePerformIO (safe: constant data).
        sed -i 's/import Graphics.PDF$/import Graphics.PDF\nimport Graphics.PDF.Fonts.StandardFont (mkStdFont, FontName(..))\nimport Data.Text (pack)\nimport System.IO.Unsafe (unsafePerformIO)/' src/OidTable.hs
        sed -i 's/author=toPDFString \$/author=pack $/' src/OidTable.hs
        sed -i '/^import Types$/a \\n{-# NOINLINE helveticaFont #-}\nhelveticaFont :: AnyFont\nhelveticaFont = unsafePerformIO $ mkStdFont Helvetica >>= either (error . show) return' src/OidTable.hs
        sed -i 's/PDFFont Helvetica/PDFFont helveticaFont/g' src/OidTable.hs
        # HPDF >= 1.7: txt now takes Data.Text.Text instead of String
        sed -i 's/paragraph \$ txt title/paragraph $ txt (pack title)/' src/OidTable.hs
        sed -i 's/paragraph \$ txt \$ "Created by tttool-"/paragraph $ txt $ pack $ "Created by tttool-"/' src/OidTable.hs
        sed -i 's/paragraph \$ txt e$/paragraph $ txt (pack e)/' src/OidTable.hs
        sed -i 's/paragraph \$ txt \$ printf/paragraph $ txt $ pack $ printf/' src/OidTable.hs
      '';
    })
  );
in
(haskell.lib.compose.justStaticExecutables tttool).overrideAttrs (_: {
  meta = {
    description = "Tool to work with files for the Ravensburger TipToi pen";
    homepage = "https://github.com/entropia/tip-toi-reveng";
    license = lib.licenses.mit;
    mainProgram = "tttool";
    platforms = lib.platforms.unix;
  };
})
