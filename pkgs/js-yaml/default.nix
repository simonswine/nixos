{
  lib,
  buildNpmPackage,
  fetchurl,
}:

buildNpmPackage rec {
  pname = "js-yaml";
  version = "4.1.0";

  src = fetchurl {
    url = "https://registry.npmjs.org/js-yaml/-/js-yaml-4.1.0.tgz";
    hash = "sha256-Da4zJVnPIrIcJupw5zKv2DA/+ZQS+cPZ0gn6qIgs8so=";
  };

  npmDepsHash = "sha256-58wdnI6K6ji2beVAp33lB35K3e4s+Vzr2MfzGXLn24U=";

  postPatch = ''
    cp ${./package-lock.json} package-lock.json
    cp ${./package.json} package.json
  '';

  dontNpmBuild = true;

  meta = {
    description = "YAML 1.2 parser and serializer";
    homepage = "https://github.com/nodeca/js-yaml";
    license = lib.licenses.mit;
  };
}
