Using Nix to run VTR tests
==========================

#### Install Nix on your machine

`curl -L https://nixos.org/nix/install | sh`

#### Create some NixOS instances

Create an image

```shell
gcloud compute images create nixos-18091228-a4c4cbb613c-x86-64-linux --source-uri gs://nixos-cloud-images/nixos-image-18.09.1228.a4c4cbb613c-x86_64-linux.raw.tar.gz
```

Create instances with that image and at least a 512GB SSD.

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
After changing `/etc/nixos/configuration.nix`, run `nix-os rebuild switch` (as root).

SSH in to each instance to check that it works and to add the remote machine to `~/.ssh/known_hosts`. Make sure that no interactive password is required (e.g. use `ssh-add` if needed.)

#### LET'S DO SOME TESTS

```shell
mkdir out
nix build -f . tests.regression_tests.vtr_reg_strong.all -j0 --builders "ssh://<ip> - - <jobs> ; ...<for each ip>"
```

If you'd like to see all the output:

```shell
nix-build -A tests.regression_tests.vtr_reg_strong.all -j0 --builders "ssh://<ip> - - <jobs> ; ...<for each ip>"

```

#### Creating a new test

Add a top level attribute to `tests.nix`, with sub-attributes for what you want to run using `make_regression_tests`.

See the top of that file for configuration options passed to `make_regression_tests`. You can select sub-tests by appending `.<test name>`.

Tests are defined in `make_regression_tests.nix`, and mirror VTR's `task_list.txt`s.
