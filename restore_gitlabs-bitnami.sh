#!/usr/bin/env bash
# This script is intended to restore a Bitnami gitlabs stack to a new machine
# from a gzip'd tarball into /opt/$VERSION
#
# Backup your existing configuration like so:
# $ tar -zcf gitlab-6.2.2-0.tar.gz /opt/gitlab-6.2.2-0/
# Be sure to follow the naming convention above

ARCHIVE="$1"
VERSION=$(basename $ARCHIVE .tar.gz)
ARGC=$#

argcheck() {
if [ $ARGC -lt $1 ]; then
        echo "Please specify a gzip'd tar archive of the bitname gitlabs directory as an argument!"
        exit 1
fi
}

# Print warning and exit if less than n arguments specified
argcheck 1

if ! file gitlab-6.2.2-0.tar.gz | grep gzip 2>/dev/null 1>/dev/null || [ ! -f $ARCHIVE ]
then
	echo "$ARCHIVE does not exist or is not a gzip'd tar archvied"
	exit 1
fi

if [ ! -d /opt/$VERSION ]
then
	echo "Extacting $ARCHIVE to /opt"
	tar -zxf $ARCHIVE -C /opt/
fi

if ! id mysql 1>/dev/null 2>/dev/null
then
	echo "Adding user mysql"
	useradd -m -s /sbin/nologin mysql
fi

if ! id git 1>/dev/null 2>/dev/null
then
	echo "Adding user git"
	useradd -m git
fi

if ! id gitlab_ci 1>/dev/null 2>/dev/null
then
	echo "Adding user gitlab_ci"
	useradd -m gitlab_ci    
fi

if ! id redis 1>/dev/null 2>/dev/null
then
	echo "Adding user redis"
	useradd -m redis
fi

if [ ! -d ~git/.ssh ]
then
	echo "Creating ~git/.ssh and setting permissions/ownership"
	mkdir ~git/.ssh
	chown git:git ~git/.ssh
	chmod 700 .ssh/
fi

if [ ! -f ~git/.ssh/authorized_keys ]; then
echo "Creating the ~git/.ssh/authorized_keys file"
cat <<AUTH_KEYS > ~git/.ssh/authorized_keys
# Add keys here. Located in ~/git/.ssh/authorized_keys
#command="/opt/gitlab-6.2.2-0/apps/gitlab/gitlab-shell/bin/gitlab-shell key-1",no-port-forwarding,no-X11-forwarding,no-agent-forwarding,no-pty ssh-rsa AAAAB3NzaC1yc2EAAAADAQasdfasdfadsfadsfQC6zzZq2q/2EnvchtNZLSrT4nuK3JW0BlLQAyzVA8pasdfasdfaweaweafdInwAF5wDZbBKGj6UzyEiFDaGqIA5XIYLGpwcvG++y/qiJsBBGNLIhusfSlhwaMpCSXYhPvlNu4dKgB51WPbX05553yWObowZ4OAFwNnFfGjMT1IxKHl1JU6DTkYl7i0CzIjZz3LUjVAaKUiCBZtiyi53VAVfTEZo+spD+JEd1IFxEyFvCLgOur+UO29Pkzr8U82RTYGruphfWamHGWBf3nqCZC4w1fKC9v3KZKJKI3MVZbJfXLXPR2/flQQiPGaCpPalW2M19d9 jonschipp@vpn-user-182.company.com
AUTH_KEYS

	chown git:git ~git/.ssh/authorized_keys
	chmod 400 ~git/.ssh/authorized_keys
fi

if [ ! -f ~git/.gitconfig ]; then
echo "Creating ~git/.gitconfig"
cat <<GITCONFIG > ~git/.gitconfig
[user]
        name = GitLab
        email = gitlab@localhost
GITCONFIG

	chown git:git ~git/.gitconfig
fi

if [ ! -f ~gitlab_ci/.gitconfig ]; then
echo "Creating ~gitlab_ci/.gitconfig"
cat <<GITCONFIG_CI > ~gitlab_ci/.gitconfig
[user]
        name = GitLab CI
        email = gitlabci@localhost
GITCONFIG_CI

	chown gitlab_ci:gitlab_ci ~gitlab_ci/.gitconfig
fi

if [ ! -L ~git/gitlab-shell ]
then
	echo "Creating symlink in ~git"
	su - git -c 'ln -s /opt/gitlab-6.2.2-0/apps/gitlab/gitlab-shell/ gitlab-shell'
fi

if [ ! -L ~gitlab_ci/gitlabci-runner ]
then
	echo "Creating symlink in ~gitlab_ci"
	su - gitlab_ci -c 'ln -s /opt/gitlab-6.2.2-0/apps/gitlabci/gitlabci-runner gitlabci-runner'
fi

if [ -d /opt/$VERSION ]
then
	echo "Setting permissions for redis, mysql, and gitlab apps"
	chown -R mysql:root /opt/$VERSION/mysql/data/
	chown redis:redis /opt/$VERSION/redis/var/log /opt/$VERSION/redis/var/log/redis-server.log
	chown -R git:git /opt/$VERSION/apps/gitlab/
	chown -R gitlab_ci:gitlab_ci /opt/$VERSION/apps/gitlabci/
fi

echo "Starting services"
/opt/$VERSION/ctlscript.sh start
echo "Done!"
