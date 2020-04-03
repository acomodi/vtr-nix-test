Using Nix to run VTR tests
==========================

#### Install Nix on your machine

`curl -L https://nixos.org/nix/install | sh`

#### Create some NixOS instances

Create an image

```shell
gcloud compute images create nixos-18091228-a4c4cbb613c-x86-64-linux --source-uri gs://nixos-cloud-images/nixos-image-18.09.1228.a4c4cbb613c-x86_64-linux.raw.tar.gz
```

Create instances with that image and at least a 128GB SSD.

For each instance, use `gcloud` or the console to log in, and add this to `/etc/nixos/configuration.nix`before the last closing `}`:

```
security.sudo.wheelNeedsPassword = false;
users.extraUsers.<your-username> = {
  createHome = true;
  home = "/home/<your-username>";
  description = "<your-name>";
  group = "users"; 
  extraGroups = [ "wheel" ];
  useDefaultShell = true;
  openssh.authorizedKeys.keys = [ "<contents of your ~/.ssh/id_rsa.pub>" ];
};

nix.maxJobs = <number of cores>;
nix.buildCores = <number of cores>;
nix.extraOptions = ''
  trusted-users = <your-username>
'';
```

#### LET'S DO SOME TESTS

```shell
mkdir out
nix build -f . regression_tests.vtr_reg_strong -j0 -o out/result --builders "ssh://<ip> - - <jobs> ; ..."
```
