PulseAudio Bluetooth User Service
=================================

**Author:** Justin Jereza

Bluetooth A2DP doesn't work properly on Linux because `module-bluetooth-discover` is loaded into PulseAudio before an X11 session has been started.

Furthermore, systemd [cannot load unit files](https://www.freedesktop.org/software/systemd/man/systemctl.html#enable%20UNIT%E2%80%A6) located in `$XDG_CONFIG_HOME/systemd/user` if the filesystem is not available at the time pid 1 is started. An example of this is when it is located on a VDO volume separate from the root filesystem.

PulseAudio-Bluetooth solves this without requiring root permissions or the modification of system files. This is done by using `$XDG_CONFIG_HOME/autostart` to reload the user systemd when an X11 session is started and getting PulseAudio into a state where `module-bluetooth-discover` can be loaded/unloaded by starting/stopping/restarting the service with `systemctl --user`.

Installation
------------

To install the files into the appropriate directories in `$XDG_CONFIG_HOME`, execute the following:

```sh
$ make install
```

Usage
-----

In case PulseAudio misbehaves, you can use the following command to attempt to fix it:

```sh
$ systemctl --user <start | stop | restart> pulseaudio-bluetooth.service
```

Uninstallation
--------------

```sh
$ make uninstall
```

