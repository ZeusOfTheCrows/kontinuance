#!/bin/bash

# set var "KTEMP" to xdg .cache if exists, else .cache
if [ -z ${XDG_CACHE_HOME+x} ]; then KTEMP="$HOME/.cache/kontinuance/"; else KTEMP="'$XDG_CACHE_HOME/kontinuance/"; fi

mkdir  -p ${KTEMP};
cd  ${KTEMP};

# setup reusables
# the ~/.themes/ and /.local/share/icons/ folders are chosen because, though inconsistent, they're the default kde locations
extract_deb () {
	ar -xv package.deb  && zstd -dq data.tar.zst  && tar -xf data.tar;
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
	copy_icons;
	# wait otherwise bash tries to cleanup before the icons are copied
	wait;
	cleanup;
}

# ---------------------------------------------------------------------------------------------------------------------------------

# download ubuntu-mono
curl -sL "http://mirrors.edge.kernel.org/ubuntu/pool/main/u/ubuntu-themes/ubuntu-mono_20.10-0ubuntu2_all.deb" -o "package.deb";

process_icons;

# download humanity icons
curl -sL "http://mirrors.edge.kernel.org/ubuntu/pool/main/h/humanity-icon-theme/humanity-icon-theme_0.6.16_all.deb" -o "package.deb";

process_icons;

# ---------------------------------------------------------------------------------------------------------------------------------

# download ambiant-mate-colours
curl -sL "https://github.com/lah7/Ambiant-MATE-Colours/releases/latest/download/ambiant-mate-colours-22.04.2.tar.xz" -o "gtk.tar.xz";

tar -xvf "gtk.tar.xz" "usr/share/themes/Ambiant-MATE-Dark-Orange/";

cp -r ./usr/share/themes/ ${HOME}/.themes/;

# fully cleanup
rm gtk.tar.xz && rm -fr ./usr/;
cd .. && rmdir kontinuance;
