Using Nix to run VTR tests
==========================

#### Install Nix on your machine

`curl -L https://nixos.org/nix/install | sh`

#### Create some NixOS instances

Create an image

```shell
gcloud compute images create nixos-18091228-a4c4cbb613c-x86-64-linux --source-uri gs://nixos-cloud-images/nixos-image-18.09.1228.a4c4cbb613c-x86_64-linux.raw.tar.gz
```

Create instances with that image and at least a 2TB SSD and an external IP.

Update the included `configuration.nix` and then for each instance:

```shell
gcloud compute scp configuration.nix <machine>:
gcloud compute ssh <machine> -t 'sudo cp configuration.nix /etc/nixos/configuration.nix; sudo nix-store --generate-binary-cache-key `hostname -s` /etc/nix/cache-priv-key.pem /etc/nix/cache-pub-key.pem; sudo nixos-rebuild switch'
```

SSH in (without the `gcloud` wrapper) to each instance to check that it works and to add the remote machine to `~/.ssh/known_hosts`. Make sure that no interactive password is required (e.g. use `ssh-add` if needed.)

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
