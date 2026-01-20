{
  dockerTools,
  pkgsStatic,
  cacert,
  gitlab-runner,
  docker-machine,
  docker-machine-driver-hetzner,
  openssh,
  runtimeShell,
  writeTextDir,
  buildEnv,
  gnumake,
}:

let
  uid = 65534;
  nonRootShadowSetup =
    {
      user,
      group ? user,
      uid,
      gid ? uid,
    }:
    [
      (writeTextDir "etc/shadow" ''
        root:!x:::::::
        ${user}:!:::::::
      '')
      (writeTextDir "etc/passwd" ''
        root:x:0:0::/root:${runtimeShell}
        ${user}:x:${toString uid}:${toString gid}::/data:
      '')
      (writeTextDir "etc/group" ''
        root:x:0:
        ${group}:x:${toString gid}:
      '')
      (writeTextDir "etc/gshadow" ''
        root:x::
        ${user}:x::
      '')
    ];
in
dockerTools.buildImage {
  name = "simonswine/gitlab-ci-runner";
  tag = "0.7.0";

  copyToRoot = buildEnv {
    name = "image-root";
    paths = [
      pkgsStatic.busybox
      pkgsStatic.dumb-init
      cacert
      gitlab-runner
      docker-machine
      docker-machine-driver-hetzner
      openssh
      gnumake
    ]
    ++ nonRootShadowSetup {
      uid = uid;
      user = "nobody";
      group = "nogroup";
    };
    pathsToLink = [
      "/bin"
      "/etc"
    ];
  };

  runAsRoot = ''
    mkdir -p ./data
    chmod 0700 ./data
    chown ${toString uid}:${toString uid} ./data
  '';

  config = {
    User = "nobody";
    Entrypoint = [
      "dumb-init"
      "--"
      "gitlab-runner"
    ];
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
