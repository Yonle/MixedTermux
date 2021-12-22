#!/usr/bin/env sh

! [ -x ~/.mixedtermuxrc ] && cat <<- EOF > ~/.mixedtermuxrc
# https://github.com/Yonle/MixedTermux
# This is a sample MixedTermux configuration file.
# This configuration file is Bash script. You can put some bash script here.

# Distribution / Distro alias
# To view the available distro, Check "proot-distro list" command
DISTRO=alpine

# User to execute as
USER=root

# Additional Proot-distro login args. Each flag is separated with space.
# See "proot-distro login --help" to see proot-distro login arguments
# ADDITIONAL_ARGS="--no-kill-on-exit --no-sysvipc"
EOF

cat <<- EOF > $PREFIX/libexec/termux/command-not-found
#!$PREFIX/bin/env bash

[ -x ~/.mixedtermuxrc ] && source ~/.mixedtermuxrc
! command -v proot-distro > /dev/null && pkg install -y proot-distro
! [ -d $PREFIX/var/lib/proot-distro/installed-rootfs/\${DISTRO:-"alpine"} ] && ! [ -z "\$(ls -A $PREFIX/var/lib/proot-distro/installed-rootfs/\${DISTRO:-"alpine"})" ] && proot-distro install \${DISTRO:-"alpine"}

ARGS=("proot-distro login \${DISTRO:-alpine}")
ARGS+=("--termux-home --shared-tmp --fix-low-ports")
! [ -z \$ADDITIONAL_ARGS ] && ARGS+=("\$ADDITIONAL_ARGS")
[ -S $(echo $TMPDIR/pulse-*/native) ] && ARGS+=("--bind $(echo $TMPDIR/pulse-*/native):/var/run/pulse/native")
ARGS+=("--user \${USER:-"root"} --") 

exec \${ARGS[@]} \$*
EOF

sed -i "s/command-not-found \"\$1\"/command-not-found \$\*/g" $PREFIX/etc/bash.bashrc

[ -r $PREFIX/share/fish/functions/fish_command_not_found.fish ] && sed -i "s/\$argv\[1\]/\"\$argv\[\@\]\"/g" $PREFIX/share/fish/functions/fish_command_not_found.fish
