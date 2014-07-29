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
command="/opt/gitlab-6.2.2-0/apps/gitlab/gitlab-shell/bin/gitlab-shell key-1",no-port-forwarding,no-X11-forwarding,no-agent-forwarding,no-pty ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC6zzZq2q/2EnvchtNZLSrT4nuK3JW0BlLQAyzVA8pDIfcdCVWqd1dio4A87JDFtFKpVaA8WuqPgInwAF5wDZbBKGj6UzyEiFDaGqIA5XIYLGpwcvG++y/qiJsBBGNLIhusfSlhwaMpCSXYhPvlNu4dKgB51WPbX05553yWObowZ4OAFwNnFfGjMT1IxKHl1JU6DTkYl7i0CzIjZz3LUjVAaKUiCBZtiyi53VAVfTEZo+spD+JEd1IFxEyFvCLgOur+UO29Pkzr8U82RTYGruphfWamHGWBf3nqCZC4w1fKC9v3KZKJKI3MVZbJfXLXPR2/flQQiPGaCpPalW2M19d9 jonschipp@vpn-user-182.ncsa.illinois.edu
command="/opt/gitlab-6.2.2-0/apps/gitlab/gitlab-shell/bin/gitlab-shell key-2",no-port-forwarding,no-X11-forwarding,no-agent-forwarding,no-pty ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCyAehPfs3GUsnTF1FRkskslQniGuA5wMH76hjDhszlSZfRzT2ljVodJUqrLgRDwhLF9seukPJ6EHXcHKnx8cdFAj/L4+fKvnnGvt6p2yiE6U3x0okvDlOpsmTrk/QDWU5yTQyq911XGPketHzM5L1UlXA85TnN+uWc8viXF6yd+4ZMfO/Ft9LoJhY7IZx5GY8ZgdZr87dIXBV4DfiujtZqaU4O0Gf1cRYLIYgiFcTEydzSGeOg4U3wdO+Quytp9m2f+Wamo9tCUXk22NQGnt8yO5P+KzKUhbogj3B6vYCgwTgN25oa2OigN6+xKo2vpbhhoidy14Pt12D9rRbsZwEl jazoff@Justins-MacBook-Air.local
command="/opt/gitlab-6.2.2-0/apps/gitlab/gitlab-shell/bin/gitlab-shell key-3",no-port-forwarding,no-X11-forwarding,no-agent-forwarding,no-pty ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAptve2sKv26YCCcxMWqx/HybXu2MWJ0OalcTywU7LBleq/UtFOCBpkghVsXy3FpcCsuq5KVCtiJtwo//ygz9IlVTUgb/w4o1sAPrDrTHdfkswvZKmW2aQuqTf7NSyaxFFHnpP4nw0lagrsyOt2ZQxQgYfOKukcI23fSo/9rXEBYItB0/ivnbIAi9VjsKg6ClI6Pz8S5Ro1uUnldkw8GRVirZ+leSn63XekQ/rV+An/Pq+dKZ922huoMmPvfcI2LbUZ4sV1z8uLWb2v8z9OzfilaTf+89/ZYBL2+zdhh5FBq3DtfvTvwRbJm1EL2hkzZPAfoFAcHcKAodTZee+p3YLoQ== soehlert@squall.ncsa.illinois.edu
command="/opt/gitlab-6.2.2-0/apps/gitlab/gitlab-shell/bin/gitlab-shell key-5",no-port-forwarding,no-X11-forwarding,no-agent-forwarding,no-pty ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDBnggc28lyFijnkPZoomOyDndFfbOV2ENMcO+u86DucH0L/ByxR/bt3AK8aNe8VtQGM89AKwu1zz+pRZZrUzVFaVb6ED0hNIQ1gZQJ62sXD5qEktMtqJKYKPGP9D+TOBdVuHJahR8msd7NFklprMq+xg8yv0x4iH4/bwQ1qYUSb6YBnmDm94/vsddEAEfo48Aj9eLDSsC9CAcxObCzXvcHvtz50KCTenA2Rfdg1c13y4XM7oA3hDSNk8pth01aRFN8xJYn4aCW8TUcmzyzF9o68GV7h5HirO9DU3L/BfXDqJwmxY4I7VaJuI5t4CTZRORpSlX+nJKvLSpSmBg2L+2r sam@wirelessprvnat-172-16-156-104.near.illinois.edu
command="/opt/gitlab-6.2.2-0/apps/gitlab/gitlab-shell/bin/gitlab-shell key-6",no-port-forwarding,no-X11-forwarding,no-agent-forwarding,no-pty ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA7YzYC8wlE9nKjjncv7bbSXpsYDGM3q5IUXyb6GYJhAZZuru+pdCFTXuIKpEDWECydxEhHqef6bXyq642+IEUEatfzh+QbZc6cCgsNTm/h6fJgQrMDLnwbp3RQ/MhSWCq9+8dRExDehVnCoLi8+gnRprnO8R9WtuNTanNo01NV9GUXyD+745vg6uysVzQkjCNROaKwAB9s2ObCitj0FSyJzlpg5Pl8yY0TDT5xeF4Yc9eHbp73SC/6rzO1eOdyetzbXXueU6hMHYEXBfPDMwQlh2C5Xpc10XCtqiKaEz2S68I9cz9S1xdqPsCirkzI6wUDSF/puaCIHCCCref+GNAJw== jazoff@drought.ncsa.illinois.edu
command="/opt/gitlab-6.2.2-0/apps/gitlab/gitlab-shell/bin/gitlab-shell key-7",no-port-forwarding,no-X11-forwarding,no-agent-forwarding,no-pty ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAr5KTsuCu0ilr8qrzlL/6U3BXiFkI3Fc9POVE+OsHLY7XCCGj0HcT6uH6GcAL+LPNdzrrnOUzlkk01ZTlPloaurxf4+N70ZJLj3YGK2kc59HmzryVXw8rIEr93rgSm8zkXeQfdVs8RpewO8e+1xtp9DzG1/FjU7mCWS3xQh+GWgYeebZCtn0cHv+iCQ1x+sgRIh2DwPu5fe461g9G5l7rKXQpjbgrAoOEoaWMFK3/1HWF8YoDvhIVpciDQ/mWOVjqDgf7F6Xu1BfR8eX1D8pFaTme2nwOUHqcOr4IqjglevIb1/KKQKqumKsrFfvXeLMPLy7BEjfqXSA+aSi1tsydIQ== root@squall.ncsa.illinois.edu
command="/opt/gitlab-6.2.2-0/apps/gitlab/gitlab-shell/bin/gitlab-shell key-8",no-port-forwarding,no-X11-forwarding,no-agent-forwarding,no-pty ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAxOG0xDQ6KKdjUBT5U5N/R0xXhAYCPkLYT43Z61foAqAGjziRNBTlEgBO21o9czvIa/EFAFG9emr14xoU1salB2XTPBShzOzXHNIHha71cX8inDttHo9zf7M711iUrH0FaOZHDgymR4kEBTLXOtuNTWe/qeb8B+PzspyxeohiwKIoSLLd6hcDvDWwPTMK7p6aUDvaVePs2cC5QuMgwfTp+h9C+EeUyfwRgVmskRNC/y5rQA/gMCMfkASFWLvI80FNmqsDVEVb0HAEHH2vlBKgEc/r8jctaFSuf7HvxmdGC8kSBmNLCsTOTiaB9uVfFeRZOGDMozE+SKJNLcdzZoq5tQ== portal@portal-sec
command="/opt/gitlab-6.2.2-0/apps/gitlab/gitlab-shell/bin/gitlab-shell key-9",no-port-forwarding,no-X11-forwarding,no-agent-forwarding,no-pty ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDHHHvmLNPLj9N24V0415DyixOA0n/kOLpzvd3OcJCOuewDxF5A9Sf8so/9+Oi09iciIKKk+bC+tiFsvd5h4WMF3Du4algK4BUXXphETr+Wao9lgQTcvdvFxPZaqK1Ouu/T1ek/A7fFpog4bS4vIwXh7eNzhuV8d3S/drBveEN13cwxV2VyiqZXZOKAtzWonI1Jb2CRJaGp3wKHHfipQYmBVVT+2D+nEo14nGSYhWZ3lBSPPth1ND5D8Z7Jt0pHtAjv0VCY/dxrchsxhKR+K89BNtFSi6kzxxBjI10ambMxRk4Q3XT5srr2nzNg3aY3Dn2xr0qWS9KYsGaQ81DDyixZ wraquel@macmonwr.ncsa.illinois.edu
command="/opt/gitlab-6.2.2-0/apps/gitlab/gitlab-shell/bin/gitlab-shell key-11",no-port-forwarding,no-X11-forwarding,no-agent-forwarding,no-pty ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA1CGc85zneMFwvoUvEyHGZQcNd6taU2441ApdVnqOqQ6+NEvoY7OPIsRdOs1Q4lg66+Q3vxKPc+9RfPnqt9jpVzy25p7/bkRgy6TXanAQMBJnRRQ1lkyi/PIola6XFZz3ag4hYxRc0OgK8a0xbQjK3LGpLbbZ5fMUizj/NhBPmD0ver3KT0JZPRjtOfXihXfcyfnVHQgbxJgcUAGl9YiMAUx38rkSUulCbk8GmNrZ6rtqE3yluX1vdyf9XH1Yr7x5d8b4cdd56a+vonm7iMdDXwLLHfjYgcgnig9AH576YGSMqeuk27hPjYrmSE45ST11O6dGn+Mh20bOPdqotEGi0Q== root@nagios-sec.internal.ncsa.edu
command="/opt/gitlab-6.2.2-0/apps/gitlab/gitlab-shell/bin/gitlab-shell key-12",no-port-forwarding,no-X11-forwarding,no-agent-forwarding,no-pty ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAug+c498S1NfL/qNX5F5dqdsXxOdcJ2uNn6Q9Mmdo45dt36/GduqKlTswOqRl+XB0WZ/S+EjqgMb7Sk2kSwlXd/0/v5kbWqBOgGIzSqe8CZiRV/QHOJeTQVmWAnaWR5Vs8auuWarmcm3APWQiT0FPhvMkycfRNPRCpn0m2WML7hOLB0aOM96mjyAe/LN8D4Q6oCmNVT039fZSthRMI8aMcu2ryQ4DE4P/mAfenGkeaY/IE2Topfuc9MhQmsiNIjFj69H1YBhd0mIt3/p8GEOuor9Qu49W2dfgyAaNCZNE6KVSHYJh5wqaXElEHHLLMLHo2XGAtuRbKnvuFYFJj9MjLw== jsiwek@tangent.ncsa.illinois.edu
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
