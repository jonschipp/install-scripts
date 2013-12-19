#!/bin/bash
# Install the Collective Intelligence Framework and all dependencies
# Configures most things too based on the documentation

# No flow control, just copied and pasted commands because of limited time

# $ cat /etc/redhat-release
# Red Hat Enterprise Linux Server release 6.4 (Santiago)

mkdir cif_build
cd cif_build

# Install EPEL mirror information
rpm --import http://dl.fedoraproject.org/pub/epel/RPM-GPG-KEY-EPEL-6
wget http://download.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm
rpm -ivh epel-release-6-8.noarch.rpm

# Install tools necessary to build other tools ;)
yum groupinstall "Development Tools"

# Grab packages
yum -y install autoconf automake bind-utils rng-tools postgresql-server httpd httpd-devel mod_ssl gcc make expat expat-devel uuid wget bind rsync libuuid-devel mod_perl ntpdate perl-Digest-SHA libxml2 libxml2-devel perl-XML-LibXML perl-DBD-Pg perl-Module-Pluggable perl-CPAN  perl-XML-Parser  perl-Net-DNS perl-IO-Socket-INET6 openssl-devel  perl-Net-SSLeay perl-Date-Manip perl-IO-Socket-SSL git

wget http://dl.fedoraproject.org/pub/epel/6/x86_64/libapreq2-2.13-1.el6.x86_64.rpm
wget http://dl.fedoraproject.org/pub/epel/6/x86_64/libapreq2-devel-2.13-1.el6.x86_64.rpm
wget http://dl.fedoraproject.org/pub/epel/6/x86_64/perl-libapreq2-2.13-1.el6.x86_64.rpm
wget http://dl.fedoraproject.org/pub/epel/6/x86_64/zeromq-2.2.0-4.el6.x86_64.rpm
wget http://dl.fedoraproject.org/pub/epel/6/x86_64/zeromq-devel-2.2.0-4.el6.x86_64.rpm
wget http://dl.fedoraproject.org/pub/epel/6/x86_64/openpgm-5.1.118-3.el6.x86_64.rpm
rpm -iv openpgm-5.1.118-3.el6.x86_64.rpm
rpm -iv libapreq2-2.13-1.el6.x86_64.rpm libapreq2-devel-2.13-1.el6.x86_64.rpm perl-libapreq2-2.13-1.el6.x86_64.rpm zeromq-2.2.0-4.el6.x86_64.rpm zeromq-devel-2.2.0-4.el6.x86_64.rpm
rm -f *.rpm

# Upgrade cpan
PERL_MM_USE_DEFAULT=1 perl -MCPAN -e "install Bundle::CPAN"

# Install perl modules necessary for CIF

for package in Module::Build YAML::Perl CPAN::Meta::YAML Test::SharedFork Test::TCP Net::Abuse::Utils Linux::Cpuinfo Google::ProtocolBuffers Iodef::Pb::Simple Compress::Snappy Net::Abuse::Utils::Spamhaus Net::DNS::Match Snort::Rule Parse::Range Log::Dispatch ZeroMQ Sys::MemInfo JSON JSON::PP JSON::XS File::Type LWP::UserAgent Class::Trigger Class::DBI Net::Patricia Text::Table Mozilla::CA IO::Socket::SSL IO::Socket::INET6 LWP::Protocol::https Text::CSV XML::RSS LWPx::ParanoidAgent UUID Class::Accessor Test::Manifest Unicode::String Config::Simple Time::Zone Capture::Tiny Test::Simple MIME::Types MIME::Lite Email::Date::Format Perl::OSType Perl::Version Module::Metadata CPAN::Meta::Requirements
do

PERL_MM_USE_DEFAULT=1 perl -MCPAN -e "install $package"

done

wget http://search.cpan.org/CPAN/authors/id/M/MA/MARKOV/MailTools-2.12.tar.gz
tar zxf MailTools-2.12.tar.gz
cd MailTools-2.12
perl Makefile.PL
make
make test
make install
cd ..

#wget http://search.cpan.org/CPAN/authors/id/D/DA/DAGOLDEN/Parse-CPAN-Meta-1.4405.tar.gz
#tar zxf Parse-CPAN-Meta-1.4405.tar.gz
#cd Parse-CPAN-Meta-1.4405
#perl Makefile.PL
#make
#make test
#make install
#cd -

#wget http://search.cpan.org/CPAN/authors/id/J/JP/JPEACOCK/version-0.9903.tar.gz
#cd version-0.9903
#perl Makefile.PL
#make
#make test
#make install
#cd -

wget ftp://ftp.ossp.org/pkg/lib/uuid/uuid-1.6.2.tar.gz
tar zxf uuid-1.6.2.tar.gz
cd uuid-1.6.2
./configure
make
make check
make install
cd perl/
perl Makefile.PL
make
make install
cd ..

wget http://search.cpan.org/CPAN/authors/id/S/SH/SHERZODR/Config-Simple-4.59.tar.gz
tar zxf Config-Simple-4.59.tar.gz
cd Config-Simple-4.59
perl Makefile.PL
make
make install
cd ..

wget ftp://ftp.pbone.net/mirror/ftp.scientificlinux.org/linux/scientific/6.1/x86_64/os/Packages/uuid-perl-1.6.1-10.el6.x86_64.rpm
rpm -ivh uuid-perl-1.6.1-10.el6.x86_64.rpm

echo "/usr/local/lib" >> /etc/ld.so.conf.d/uuid.conf
ldconfig

PERL_MM_USE_DEFAULT=1 perl -MCPAN -e "install Iodef::Pb::Simple"

sed -i 's/^Listen/#/' /etc/httpd/conf/httpd.conf

cat <<EOF > /etc/httpd/conf.d/cif.conf
<Location /api>
    SetHandler perl-script
    PerlResponseHandler CIF::Router::HTTP
    PerlSetVar CIFRouterConfig "/home/cif/.cif"
</Location>
EOF

sed -i '75i\\tPerlRequire /opt/cif/bin/http_api.pl\n\tInclude /etc/httpd/conf.d/cif.conf\n' /etc/httpd/conf.d/ssl.conf

useradd cif
chmod 770 /home/cif
usermod -a -G cif apache

cat <<EOF > /etc/named.conf
//
// named.conf
//
// Provided by Red Hat bind package to configure the ISC BIND named(8) DNS
// server as a caching only nameserver (as a localhost DNS resolver only).
//
// See /usr/share/doc/bind*/sample/ for example named configuration files.
//

options {
        listen-on port 53 { 127.0.0.1; };
        directory       "/var/named";
        dump-file       "/var/named/data/cache_dump.db";
        statistics-file "/var/named/data/named_stats.txt";
        memstatistics-file "/var/named/data/named_mem_stats.txt";
        allow-query     { localhost; };
        recursion yes;
        auth-nxdomain no;    # conform to RFC1035 dnssec-enable yes; dnssec-validation yes;
        dnssec-lookaside auto;

        /* Path to ISC DLV key */
        bindkeys-file "/etc/named.iscdlv.key";

        managed-keys-directory "/var/named/dynamic";

        forward only;
        forwarders {
        8.8.8.8;
        8.8.4.4;
    };

};

logging {
        channel default_debug {
                file "data/named.run";
                severity dynamic;
        };
};

zone "." IN {
        type hint;
        file "named.ca";
};

// bypass the Google public servers
zone "cymru.com" {
    forward only;
    type forward;
    forwarders { };
};

zone "zen.spamhaus.org" {
    forward only;
    type forward;
    forwarders { };
};

zone "dbl.spamhaus.org" {
    forward only;
    type forward;
    forwarders { };
};

include "/etc/named.rfc1912.zones";
include "/etc/named.root.key";
EOF

sed -i '/DNS1/d' /etc/sysconfig/network-scripts/ifcfg-eth0
echo 'DNS1="127.0.0.1"' >> /etc/sysconfig/network-scripts/ifcfg-eth0
echo 'nameserver 127.0.0.1' > /etc/resolv.conf

service named restart

mkdir -p /mnt/archive
mkdir -p /mnt/index
mkdir -p /mnt/pg_xlog
chown postgres:postgres /mnt/archive
chown postgres:postgres /mnt/index
chown postgres:postgres /mnt/pg_xlog
mkdir -p /etc/postgresql/8.4/main

service postgresql stop

service postgresql initdb
service postgresql restart

service postgresql stop

mv /var/lib/pgsql/pg_xlog/* /mnt/pg_xlog/
rm -rf /var/lib/pgsql/main/pg_xlog
ln -sf /mnt/pg_xlog /var/lib/pgsql/main/pg_xlog

ln -sf /var/lib/pgsql/data/postgresql.conf /etc/postgresql/8.4/main/postgresql.conf
ln -sf /var/lib/pgsql/data/pg_hba.conf /etc/postgresql/8.4/main/pg_hba.conf

cat <<EOF > /var/lib/pgsql/data/pg_hba.conf
# PostgreSQL Client Authentication Configuration File
# ===================================================
#
# Refer to the "Client Authentication" section in the
# PostgreSQL documentation for a complete description
# of this file.  A short synopsis follows.
#
# This file controls: which hosts are allowed to connect, how clients
# are authenticated, which PostgreSQL user names they can use, which
# databases they can access.  Records take one of these forms:
#
# local      DATABASE  USER  METHOD  [OPTIONS]
# host       DATABASE  USER  CIDR-ADDRESS  METHOD  [OPTIONS]
# hostssl    DATABASE  USER  CIDR-ADDRESS  METHOD  [OPTIONS]
# hostnossl  DATABASE  USER  CIDR-ADDRESS  METHOD  [OPTIONS]
#
# (The uppercase items must be replaced by actual values.)
#
# The first field is the connection type: "local" is a Unix-domain socket,
# "host" is either a plain or SSL-encrypted TCP/IP socket, "hostssl" is an
# SSL-encrypted TCP/IP socket, and "hostnossl" is a plain TCP/IP socket.
#
# DATABASE can be "all", "sameuser", "samerole", a database name, or
# a comma-separated list thereof.
#
# USER can be "all", a user name, a group name prefixed with "+", or
# a comma-separated list thereof.  In both the DATABASE and USER fields
# you can also write a file name prefixed with "@" to include names from
# a separate file.
#
# CIDR-ADDRESS specifies the set of hosts the record matches.
# It is made up of an IP address and a CIDR mask that is an integer
# (between 0 and 32 (IPv4) or 128 (IPv6) inclusive) that specifies
# the number of significant bits in the mask.  Alternatively, you can write
# an IP address and netmask in separate columns to specify the set of hosts.
#
# METHOD can be "trust", "reject", "md5", "password", "gss", "sspi", "krb5",
# "ident", "pam", "ldap" or "cert".  Note that "password" sends passwords
# in clear text; "md5" is preferred since it sends encrypted passwords.
#
# OPTIONS are a set of options for the authentication in the format
# NAME=VALUE. The available options depend on the different authentication
# methods - refer to the "Client Authentication" section in the documentation
# for a list of which options are available for which authentication methods.
#
# Database and user names containing spaces, commas, quotes and other special
# characters must be quoted. Quoting one of the keywords "all", "sameuser" or
# "samerole" makes the name lose its special character, and just match a
# database or username with that name.
#
# This file is read on server startup and when the postmaster receives
# a SIGHUP signal.  If you edit the file on a running system, you have
# to SIGHUP the postmaster for the changes to take effect.  You can use
# "pg_ctl reload" to do that.

# Put your actual configuration here
# ----------------------------------
#
# If you want to allow non-local connections, you need to add more
# "host" records. In that case you will also need to make PostgreSQL listen
# on a non-local interface via the listen_addresses configuration parameter,
# or via the -i or -h command line switches.
#

# TYPE  DATABASE    USER        CIDR-ADDRESS          METHOD

# "local" is for Unix domain socket connections only
#local   all         all                               ident
local   all         postgres                          trust
# IPv4 local connections:
#host    all         all         127.0.0.1/32          ident
host    all         all         127.0.0.1/32          trust
# IPv6 local connections:
#host    all         all         ::1/128               ident
host    all         all         ::1/128               trust
EOF

service postgresql start

sed '/EXTRA/d' /etc/sysconfig/rngd
echo 'EXTRAOPTIONS="-r /dev/urandom"' >> /etc/sysconfig/rngd
service rngd restart

mkdir /var/log/cif
chown cif:cif /var/log/cif

cat <<EOF > /etc/logrotate.d/cif
/var/log/cif/*.log {
          weekly
          rotate 52
          compress
          notifempty
          missingok
          nocreate
}
EOF

chkconfig --levels 345 postgresql on
chkconfig --levels 345 named on
chkconfig --levels 345 rngd on
chkconfig --levels 345 httpd on

# Download and install CIF

wget https://github.com/collectiveintel/cif-v1/releases/download/1.0.0/cif-v1-1.0.0.tar.gz -O cif-v1-1.0.0.tar.gz
tar zxf cif-v1-1.0.0.tar.gz
cd cif-v1-1.0.0
./configure
make testdeps && make install && make initdb

# Install cif-v1 from github (not recommended)
#git clone --recursive https://github.com/collectiveintel/cif-v1
#cd cif-v1
#autoconf
#autoreconf -vfi
#automake --add-missing
#./configure
#make all
#make initdb
#make install

for user in /root /home/cif
do

cat <<EOF > $user/.cif

# the simple stuff
# cif_archive configuration is required by cif-router, cif_feed (cif-router, libcif-dbi)
[cif_archive]
# if we want to enable rir/asn/cc, etc... they take up more space in our repo
# datatypes = infrastructure,domain,url,email,search,malware,cc,asn,rir
datatypes = infrastructure,domain,url,email,search,malware

# if you're going to enable feeds
# feeds = infrastructure,domain,url,email,search,malware
feeds = infrastructure,domain,url,email,search,malware

# enable your own groups is you start doing data-sharing with various groups
#groups = everyone,group1.example.com,group2.example.com,group3.example.com

# client is required by the client, cif_router, cif_smrt (libcif, cif-router, cif-smrt)
[client]
# the apikey for your client
apikey =

[client_http]
host = https://localhost:443/api
verify_tls = 0

# cif_smrt is required by cif_smrt
[cif_smrt]
# change example.com to your local domain and hostname respectively
# this identifies the data in your instance and ties it to your specific instance in the event
# that you start sharing with others
#name = example.com
#instance = cif.example.com
name = localhost
instance = cif.localhost

# the apikey for cif_smrt
apikey =

# advanced stuff
# db config is required by cif-router, cif_feed, cif_apikeys (cif-router, libcif-dbi)
[db]
host = 127.0.0.1
user = postgres
password =
database = cif

# if the normal IODEF restriction classes don't fit your needs
# ref: https://code.google.com/p/collective-intelligence-framework/wiki/RestrictionMapping_v1
# restriction map is required by cif-router, cif_feed (cif-router, libcif-dbi)
[restriction_map]
#white = public
#green = public
#amber = need-to-know
#red   = private

# logging
# values 0-4
[router]
# set to 0 if it's too noisy and reload the cif-router (apache), only on for RC2
debug = 1

[cif_feed]
# max size of any feed generated
limit = 50000
#
# # each confidence level to generate
confidence = 95,85,75,65
#
# # what 'role' keys to use to generate the feeds
roles = role_everyone_feed
#
# # how far back in time to generate the feeds from
limit_days = 7
#
# # how many days of generated feeds to keep in the archive
feed_retention = 7
EOF

done
