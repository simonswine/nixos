{ config, ... }: {

  services.openssh.enable = true;
  users.extraUsers.root.openssh.authorizedKeys.keys =
    config.swine.ssh.pubkeys.simonswine ++
    config.swine.ssh.pubkeys.benedikt;

}

