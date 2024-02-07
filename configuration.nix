{ inputs, flake, ... }:
{ pkgs, ... }:
let
  pyenv = (pkgs.python311.withPackages (pp: [
    flake.packages.${pkgs.system}.xnvme-py
    pp.jupyter
    pp.notebook
    pp.jupyter-core
    pp.pytest
    pp.ipykernel
  ]));
  sshKey = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDfiSeJDvonf1w5dNk5V+KcGvKODQva5PUxAO0UZYBvXbZwxuBnFQ0VGgvONRF/Sct+phdI4GFFKliDqZc9KtNiyM9SNjOrNQQfLJgWNHPmWNABx3gfFvQygNoTsS9GxulMitdGUtrXuK5l4yLAU1INC97v3/qIqjGSu9pPqnNWyWMa1d2VWa8QkA2zDSC0J1+ytt/ZqwtAyxP86lVjTb4aDpdRY3ucZH8xvk9sIR2gJsFXm9Tz58PJh/FEvJ/X9FTBkm8qq6/KDN2wNbJ/Bs7/x9rg4UmEhKpN3bStRVOOHPotUOxZ2I/uIUlMn9CIDhqVVTU6XruFVdUwzdUzbvyAKrcbcV8LdVdeOBRkTZgz9s7plHMl/Q2I1KGhecEqiGLwL7v3BJibf/S/saCSmziLU6FYrR8w8FtRStKKTaz7sE/50eVWBkQX+wFFsLw8HLdjJnHXBUZDHgYzXoVAAVFbzZxeA8E5924YF8bgLBkqn2FBrFnHiBgArkHWuv2I6V+gw9hMjPEQJje5h2E2l/NzL0sq/dlh7CXoJVf/9K6GM3fCjWfcJOmdu50sBzqFmIEZIgbGJnEkdRnCglk3VbBqNyMdhKKVBL5dRRmEBF2FbfoWCAihGW8sodZWbDMMZalzW1cgofA4LUrFQRktuR+G0cT73bBw0VbnZjuVF5Bq4w== samsung 2021-02-16";
in {
  # variable pertaining to package defaults.
  # generally, never CHANGE after initial setup.
  # @ initial setup, set it to match the release you're tracking (e.g. nixos-22.11 => 22.11)
  system.stateVersion = "23.11";

  nix = {
    # enable new CLI and flake support
    package = pkgs.nixFlakes;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  users.users.root = {
    # allow logging into `root` without a password
    initialHashedPassword = "";
    openssh.authorizedKeys.keys = [ sshKey ];
  };

  # install user `nixusr`
  users.users.nixusr = {
    isNormalUser = true;
    home = "/home/nixusr";
    description = "nixusr user";
    extraGroups = [ "wheel" ];
    uid = 1000;
    # `mkpasswd -m sha-512` | default: nix4noobs
    hashedPassword =
      "$6$Hgsy/oWyd7JzGsNA$6dezfToj2LR4QChD7FpMgaKMZI../utuSjwClAElL2R8WCF7Md7ZXnMNGBMP6K50mKcOimgKN29TkrAr2D/6R/";
    openssh.authorizedKeys.keys = [ sshKey ];
  };

  # configure OpenSSH service
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "yes";
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
    };
  };

  systemd.services."jupyter" = {
    description = "jupyter notebook server";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    path = [ pyenv ];
    serviceConfig = {
      Type = "simple";
      User = "root";
      ExecStart =
        "${pkgs.python311Packages.jupyter-core}/bin/jupyter notebook --ip 0.0.0.0 --port 8888 --NotebookApp.password=\\'\\' --NotebookApp.token=\\'\\' --allow-root ";
      WorkingDirectory = "/var/notebook";
    };
  };

  security.sudo.wheelNeedsPassword = false;

  networking.firewall.enable = false;

  # extra software to install
  environment.systemPackages =
    (with flake.packages.${pkgs.system}; [ libvfn xnvme ]) ++ [ pyenv ]
    ++ (with pkgs; [ neovim ]);

  systemd.tmpfiles.rules = [ "d /var/notebook 0755 root root" ];
}
