{ pkgs }:

let
  uid = 65534;
  nonRootShadowSetup = { user, group ? user, uid, gid ? uid }: with pkgs; [
    (
      writeTextDir "etc/shadow" ''
        root:!x:::::::
        ${user}:!:::::::
      ''
    )
    (
      writeTextDir "etc/passwd" ''
        root:x:0:0::/root:${runtimeShell}
        ${user}:x:${toString uid}:${toString gid}::/data:
      ''
    )
    (
      writeTextDir "etc/group" ''
        root:x:0:
        ${group}:x:${toString gid}:
      ''
    )
    (
      writeTextDir "etc/gshadow" ''
        root:x::
        ${user}:x::
      ''
    )
  ];
in
pkgs.dockerTools.buildImage {
  name = "simonswine/gitlab-ci-runner";
  tag = "0.1.2";

  contents = [
    pkgs.pkgsStatic.busybox
    pkgs.cacert
    pkgs.gitlab-runner
    pkgs.docker-machine
    pkgs.docker-machine-driver-hetzner
    pkgs.openssh
  ] ++ nonRootShadowSetup { uid = uid; user = "nobody"; group = "nogroup"; };

  runAsRoot = ''
    mkdir -p ./data
    chmod 0700 ./data
    chown ${toString uid}:${toString uid} ./data
  '';

  config = {
    User = "nobody";
    Entrypoint = [ "gitlab-runner" ];
    WorkingDir = "/data";
    Volumes = {
      "/data" = { };
    };
    Env = [
      "HOME=/data"
      "USER=nobody"
    ];
  };
}
