{ ... }:

# Customize these variables

let
# ========================================

  # User info
  user = "<username>";
  user_name = "<full name>";

  # Client SSH public key
  ssh_key = "<contents of your ~/.ssh/id_rsa.pub>";

  # Builder's core count
  cores = 96;

# ========================================

in {
  imports = [ <nixpkgs/nixos/modules/virtualisation/google-compute-image.nix> ];

  security.sudo.wheelNeedsPassword = false;
  users.extraUsers.${user} = {
    createHome = true;
    home = "/home/${user}";
    description = user_name;
    group = "users";
    extraGroups = [ "wheel" ];
    useDefaultShell = true;
    openssh.authorizedKeys.keys = [ ssh_key ];
  };

  nix.maxJobs = cores;
  nix.buildCores = cores;
  nix.extraOptions = ''
  trusted-users = ${user}
  secret-key-files = /etc/nix/cache-priv-key.pem
'';

}
