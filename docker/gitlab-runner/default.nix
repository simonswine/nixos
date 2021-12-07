{ pkgs }:
pkgs.dockerTools.buildLayeredImage {
  name = "simonswine/gitlab-ci-runner";
  # TODO: Find a way to determine from git tags
  tag = "0.1.0";
  contents = [
    pkgs.pkgsStatic.busybox
    pkgs.cacert
    pkgs.gitlab-runner
    pkgs.docker-machine
  ];
  config = {
    Cmd = "jsonnet-exporter";
  };
}
