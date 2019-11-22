PulseAudio Bluetooth User Service
=================================

**Author:** Justin Jereza

Bluetooth HSP/A2DP doesn't work properly on Linux because `module-bluetooth-policy` and `module-bluetooth-discover` are loaded into PulseAudio before a graphical session has been started.

Furthermore, systemd [cannot load unit files](https://www.freedesktop.org/software/systemd/man/systemctl.html#enable%20UNIT%E2%80%A6) located in `$XDG_CONFIG_HOME/systemd/user` if the filesystem is not available at the time pid 1 is started. An example of this is when it is located on a VDO volume separate from the root filesystem.

PulseAudio-Bluetooth solves this with minimal modification to the system configuration. This is done by using `$XDG_CONFIG_HOME/autostart` to reload the user systemd when a graphical session is started and getting PulseAudio into a state where `module-bluetooth-policy` and `module-bluetooth-discover` can be loaded/unloaded by starting/stopping/restarting the service with `systemctl --user`.

Possible Permanent Solutions
----------------------------

One option to fix this problem is to patch [upstream](https://cgit.freedesktop.org/pulseaudio/pulseaudio/) such that Bluetooth module loading is handled by `start-pulseaudio-x11` instead.

Another option is to have `pulseaudio.service` start after `graphical-session.target`. This target seems to be the most logical dependency since there is no generic unit available earlier than this that can guarantee that a graphical session is available. The downside to this approach is that PulseAudio is not completely independent of a graphical session unless a way can be found such that `pulseaudio.service`'s dependency on `graphical-session.target` is only active if a graphical session has indeed been started by the user. In this case, it seems this option is no better than just handling module loading in `start-pulseaudio-x11`.

A longer-term solution is to find out why Bluetooth breaks when the modules are loaded before a graphical session is available. Solving this will allow PulseAudio to function in a user session regardless of whether a graphical session has been started or not.

Prerequisites
-------------

Remove all `load-module` statements for `module-bluetooth-policy` and `module-bluetooth-discover` in `/etc/pulse/default.pa`. As an example, on EL8 you can comment out the entire `.ifexists` blocks for these modules. This is the only thing that needs to be done that, unfortunately, requires root permissions.

Installation
------------

To install the files into the appropriate directories in `$XDG_CONFIG_HOME`, execute the following:

```sh
$ make install
```

Logout and log back in to get the modules loaded in the correct order.

Usage
-----

In case PulseAudio Bluetooth misbehaves, you can use the following command to attempt to fix it:

```sh
$ systemctl --user <start | stop | restart> pulseaudio-bluetooth.service
```

Verification
------------

To verify that the modules have been loaded properly, run `pactl list short modules`. There should only be one of each of `module-bluetooth-policy`, `module-bluetooth-discover`, and `module-bluez5-discover` on the list and they should be the last modules loaded.

Example of desired output:

```
0       module-device-restore
1       module-stream-restore
2       module-card-restore
3       module-augment-properties
4       module-switch-on-port-available
5       module-udev-detect
6       module-esound-protocol-unix
7       module-native-protocol-unix
8       module-default-device-restore
9       module-rescue-streams
10      module-always-sink
12      module-intended-roles
13      module-suspend-on-idle
14      module-systemd-login
15      module-position-event-sounds
16      module-role-cork
17      module-filter-heuristics
18      module-filter-apply
19      module-alsa-card        device_id="0" name="pci-0000_00_1f.3" card_name="alsa_card.pci-0000_00_1f.3" namereg_fail=false tsched=yes fixed_latency_range=no ignore_dB=no deferred_volume=yes use_ucm=yes card_properties="module-udev-detect.discovered=1"
20      module-x11-publish      display=:0 xauthority=
21      module-x11-cork-request display=:0 xauthority=
22      module-x11-xsmp display=:0 xauthority= session_manager=local/unix:@/tmp/.ICE-unix/5255,unix/unix:/tmp/.ICE-unix/5255
23      module-bluetooth-policy
24      module-bluetooth-discover
25      module-bluez5-discover
```

Uninstallation
--------------

```sh
$ make uninstall
```

