#!/usr/bin/env sh

! [ -f ~/.mixedtermuxrc ] && cat <<- EOF > ~/.mixedtermuxrc
# https://github.com/Yonle/MixedTermux
# This is a sample MixedTermux configuration file.
# This configuration file is Bash script. You can put some bash script here.

# Distribution / Distro alias
# To view the available distro, Check "proot-distro list" command
DISTRO=alpine

# User to execute as
USER=root

# Keep all environment variables
KEEPENV=1

# Filter some environment variable that should not store
# Each variables splitted by name
FILTER_ENV="SHELL PREFIX PATH LD_PRELOAD LD_LIBRARY_PATH"

# Additional Proot-distro login args. Each flag is separated with space.
# See "proot-distro login --help" to see proot-distro login arguments

# ADDITIONAL_ARGS="--no-kill-on-exit --no-sysvipc"
EOF

cat <<- EOF > $PREFIX/libexec/termux/command-not-found
#!$PREFIX/bin/env bash

DISTRO_PATH=$PREFIX/var/lib/proot-distro/installed-rootfs/\${DISTRO:-"alpine"}

[ -f ~/.mixedtermuxrc ] && source ~/.mixedtermuxrc
! command -v proot-distro > /dev/null && pkg install -y proot-distro
! [ -d \$DISTRO_PATH ] && ! [ -z "\$(ls -A \$DISTRO_PATH)" ] && proot-distro install \${DISTRO:-"alpine"}

environments=""

! [ -z "\$KEEPENV" ] && for i in \$(env); do
	filtered=0
	# Don't put some filtered variables
	for env in \$FILTER_ENV; do
		(echo \$i | grep -qo \$env) && filtered=1
	done
	[ "\$filtered" = 0 ] && environments="\$environments export \$i;"
done

cat <<- END > \$DISTRO_PATH/etc/profile.d/mixedtermux.sh
#!/usr/bin/env sh

\$environments

cd \$(pwd)
rm /etc/profile.d/mixedtermux.sh
END

chmod +x \$DISTRO_PATH/etc/profile.d/mixedtermux.sh

ARGS=("proot-distro login \${DISTRO:-alpine}")
ARGS+=("--termux-home --shared-tmp --fix-low-ports")
! [ -z "\$ADDITIONAL_ARGS" ] && ARGS+=("\$ADDITIONAL_ARGS")
[ -S $(echo \$TMPDIR/pulse-*/native) ] && ARGS+=("--bind \$(echo \$TMPDIR/pulse-*/native):/var/run/pulse/native")
ARGS+=("--bind \$(pwd) --user \${USER:-"root"} --") 

exec \${ARGS[@]} \$*
EOF

sed -i "s/command-not-found \"\$1\"/command-not-found \$\*/g" $PREFIX/etc/bash.bashrc

[ -r $PREFIX/share/fish/functions/fish_command_not_found.fish ] && sed -i "s/\$argv\[1\]/\"\$argv\"/g" $PREFIX/share/fish/functions/fish_command_not_found.fish
