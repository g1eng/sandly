## Sandly - thin desktop application sandbox builder with docker/podman 

`Sandly` is docker-based application sandbox for Linux native GUI applications. Historically, it is rewritten from [OpenCDI](https://github.com/OpenCDI/opencdi-scripts), [cosh](https://gist.github.com/g1eng/46f9ec7807ccc56f80105eaec7965ac8) and so on. Do not track on dark side past... 

[Flatpak](https://flatpak.io) has been widely used to softly jail GUI applications. However it has fat layers under GUI applications such as X11 compatibility libraries and Freedesktop related contents. If you have linux desktop, these dependencies are already installed in your system in many cases, but flatpak needs to re-install them! 

Several design concepts required flatpak team to do so (to make flatpak os-independent runtime, to isolate flatpak's binary attack surfaces from system libraries outside sandbox, etc.).

Sandly does not provide its own images or additional layers for target applications, but it has a thin skeleton image (~83kB) for any applications. If you need, some additional network functionalities can be deployed into the container network.

# Requirements

[runtime]

* dockerd (in [rootless mode](https://docs.docker.com/engine/security/rootless/))
* podman (if you unlike docker)
* GUI application installation in your system
* userns remap configuration (/etc/subuid and /etc/subgid)
* xhost
* XWayland (for wayland users)

[image and wrapper script builder]

* dockerd
* GNU make

#### Attention

* **It is highly recommended to use docker with rootlesskit, because a system-level dockerd seems to have priviledges in some conditions for your system, outside containers.**
* It is recommended to protect and monitor your `dockerd.sock` with certain access control or auditing mechanisms.

# Installation

1. write `app_list.txt`

Sandly does not provide its prebuilt images and you need to build you own skeleton image.
The build script needs to parse `app_list.txt` in the top of the repository. `app_list.txt` is a simple list of applications to be sandboxed, and it is a set of full path of the application binaries. 

Be careful not to specify application wrapper script such as `/usr/bin/firefox` (shell script) in some distributions. You must specify application ELF binaries per line to run them inside containers.

For example, see `app_list_sample.txt`.

2. build images, generate wrapper scripts, install them

```shell-session
$ make
$ PREFIX=$HOME/local make install
```

If you want to install sandly script with podman, specify SANDLY_DOCKERIAN variable to generate wrapper scirpt for podman:

```shell-session
$ SANDLY_DOCKERIAN=/usr/bin/podman make
$ PREFIX=$HOME/local make install
```

3. ensure your desktop adopts window projection of apps

(For wayland users: install XWayland at first.)

Sandly depends on socket pass through by dockerd. It binds the X11's display socket insides container and projects app screen to the display, specified with the DISPLAY environmental variable. xhost relizes screen projection via X11 socket with simple access control mechanism.
Ensure X11 to permit local (in-machine) connection to the socket:

```bash
xhost +local$DISPLAY
```

Or you will prefer to write it in the ~/.xinitrc or ~/.xprofile.

```bash
{ read $line; echo $line; } << EOS >> ~/.xprofile
xhost +local\$DISPLAY
EOS
```

4. check rootless docker is running

```shell-session
$ ps awux  | grep -E \^$USER\ \.\+dockerd\$
```

5. play

```shell-session
$ $HOME/local/firefox
```

or modify PATH variable to invoke them without full path.

```bash
{ read $line; echo $line; } << EOS >> ~/.bash_profile
PATH=\$HOME/local/bin:\$PATH
EOS
```

# Author 

Nomura Suzume
