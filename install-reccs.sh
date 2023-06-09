#!/bin/bash

# set var "KTEMP" to xdg cache if exists, else .cache
KTEMP=${XDG_CACHE_HOME:-${HOME}/.cache}/kontinuance

mkdir  -p ${KTEMP};
cd  ${KTEMP};

# setup reusables
# the ~/.themes/ and /.local/share/icons/ folders are chosen because, though
# inconsistent, they're the default kde locations
extract_deb () {
	ar -xv package.deb  && zstd -dq data.tar.zst  && tar -xf data.tar;
}

improve_inheritance () {
	sed -i -e "s/Inherits=Humanity-Dark,Adwaita,hicolor/Inherits=Humanity-Dark,oxygen,gnome,breeze-dark,Adwaita,hicolor/" \
		./usr/share/icons/ubuntu-mono-dark/index.theme;
	sed -i -e "s/Inherits=Humanity,Adwaita,hicolor/Inherits=Humanity,oxygen,gnome,Adwaita,hicolor/" \
		./usr/share/icons/ubuntu-mono-light/index.theme;
}

copy_icons () {
	cp -r ./usr/* ${HOME}/.local/
}

cleanup () {
	rm control.tar.zst data.tar data.tar.zst debian-binary;
	rm -fr ./usr/;
	rm package.deb;
}

process_icons () {
	extract_deb;
	wait;
	improve_inheritance;
	copy_icons;
	# wait otherwise bash tries to cleanup before the icons are copied
	wait;
	cleanup;
}

# ------------------------------------------------------------------------------

# download ubuntu-mono
curl -sL "http://mirrors.edge.kernel.org/ubuntu/pool/main/u/ubuntu-themes/ubuntu-mono_20.10-0ubuntu2_all.deb" -o "package.deb";

process_icons;

# download humanity icons
curl -sL "http://mirrors.edge.kernel.org/ubuntu/pool/main/h/humanity-icon-theme/humanity-icon-theme_0.6.16_all.deb" -o "package.deb";

process_icons;

# ------------------------------------------------------------------------------

# download ambiant-mate-colours
curl -sL "https://github.com/lah7/Ambiant-MATE-Colours/releases/latest/download/ambiant-mate-colours-22.04.2.tar.xz" -o "gtk.tar.xz";

tar -xvf "gtk.tar.xz" "usr/share/themes/Ambiant-MATE-Dark-Orange/";

cp -r ./usr/share/themes/ ${HOME}/.themes/;

# fully cleanup
cd .. && rm -fr ${KTEMP};
