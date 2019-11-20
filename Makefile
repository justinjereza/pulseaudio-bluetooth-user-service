.PHONY = all install install-autostart install-systemd-user uninstall

XDG_CONFIG_HOME ?= ${HOME}/.config
XDG_CONFIG_AUTOSTART = ${XDG_CONFIG_HOME}/autostart
XDG_CONFIG_SYSTEMD = ${XDG_CONFIG_HOME}/systemd
XDG_CONFIG_SYSTEMD_USER = ${XDG_CONFIG_SYSTEMD}/user

all:
	@echo "Usage: make <install | install-systemd-user>"

install: install-autostart install-systemd-user

install-autostart:
	install -m 0644 -CDt "${XDG_CONFIG_AUTOSTART}" "pulseaudio-bluetooth.desktop"

install-systemd-user:
	install -m 0644 -CDt "${XDG_CONFIG_SYSTEMD_USER}" "pulseaudio-bluetooth.service"

uninstall:
	-rm "${XDG_CONFIG_AUTOSTART}/pulseaudio-bluetooth.desktop" "${XDG_CONFIG_SYSTEMD_USER}/pulseaudio-bluetooth.service"
	-find "${XDG_CONFIG_AUTOSTART}" "${XDG_CONFIG_SYSTEMD}" -type d -exec rmdir {} +
