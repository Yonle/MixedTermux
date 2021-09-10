#!/data/data/com.termux/files/usr/bin/sh

if ! [ -d $HOME/alpine-proot ]; then
	mkdir -p $HOME/alpine-proot
	curl -sLo $HOME/alpine-proot/main.sh git.io/alpine-proot
	chmod +x $HOME/alpine-proot/main.sh
fi

cat <<- EOF > /data/data/com.termux/files/usr/libexec/termux/command-not-found
#!/data/data/com.termux/files/usr/bin/env sh

export ALPINEPROOT_BIND_TMPDIR=1
export ALPINEPROOT_PROOT_OPTIONS=" -b \$(pwd) -b /data -b /sdcard -b /storage"

/data/data/com.termux/files/home/alpine-proot/main.sh -c "cd \$(pwd) && \$@"
EOF

sed -i "s/command-not-found \"\$1\"/command-not-found \"\$\@\"/g" /data/data/com.termux/files/usr/etc/bash.bashrc

if [ -r /data/data/com.termux/files/usr/share/fish/functions/fish_command_not_found.fish ]; then
	sed -i "s/\$argv\[1\]/\"\$argv\"/g" /data/data/com.termux/files/usr/share/fish/functions/fish_command_not_found.fish
fi
