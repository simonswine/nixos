{
  lib,
  buildGoModule,
  fetchFromGitLab,
}:

let
  version = "17.10.1";
in
buildGoModule rec {
  inherit version;
  pname = "gitlab-runner";

  commonPackagePath = "gitlab.com/gitlab-org/gitlab-runner/common";
  ldflags = [
    "-X ${commonPackagePath}.NAME=gitlab-runner"
    "-X ${commonPackagePath}.VERSION=${version}"
    "-X ${commonPackagePath}.REVISION=v${version}"
  ];

  vendorHash = "sha256-1NteDxcGjsC0kT/9u7BT065EN/rBhaNznegdPHZUKxo=";

  src = fetchFromGitLab {
    owner = "gitlab-org";
    repo = "gitlab-runner";
    rev = "v${version}";
    hash = "sha256-pLmDWZHxd9dNhmbcHJRBxPuY0IpcJoXz/fOJeP1lVlA=";
  };

  subPackages = [ "." ];

  postInstall = ''
    install packaging/root/usr/share/gitlab-runner/clear-docker-cache $out/bin
  '';

  doCheck = false;

  meta = with lib; {
    description = "GitLab Runner the continuous integration executor of GitLab";
    license = licenses.mit;
    homepage = "https://docs.gitlab.com/runner/";
    platforms = platforms.unix ++ platforms.darwin;
    maintainers = with maintainers; [ zimbatm ] ++ teams.gitlab.members;
  };
}
