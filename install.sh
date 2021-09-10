#!/data/data/com.termux/files/usr/bin/sh

if ! [ -d $HOME/alpine-proot ]; then
	mkdir -p $HOME/alpine-proot
	curl -sLo $HOME/alpine-proot/main.sh git.io/alpine-proot
	chmod +x $HOME/alpine-proot/main.sh
fi

cat <<- EOF > /data/data/com.termux/files/usr/libexec/termux/command-not-found
#!/data/data/com.termux/files/usr/bin/env sh

export ALPINEPROOT_BIND_TMPDIR=1
export ALPINEPROOT_PROOT_OPTIONS=" -b \$(pwd)"

/data/data/com.termux/files/home/alpine-proot/main.sh -c "cd \$(pwd) && \$@"
EOF

