#!/bin/sh

set -e -x

SCRIPT_DIR=$(readlink -f $(dirname $0))
. $SCRIPT_DIR/lib.sh

pkg=bugzilla-4.2

[ -d /srv/www/bugzilla ] || {
    [ ! -e /srv/www/$pkg ] || mv /srv/www/$pkg /srv/www/$pkg-`date +%Y%m%d-%H%M%S`
    rm -f /tmp/$pkg.tar.gz
    wget -O /tmp/$pkg.tar.gz 'http://ftp.mozilla.org/pub/mozilla.org/webtools/bugzilla-4.2.tar.gz'
    [ 7c712b26fbf7d8684f57c2e89caff422 = `md5sum /tmp/$pkg.tar.gz` ] &&
        [ 9ecde503712de41f90d84cdb5bf892841ad16840 = `sha1sum /tmp/$pkg.tar.gz` ]

    tar --no-same-owner -C /srv/www -zxvf /tmp/$pkg.tar.gz || {
        /bin/rm -rf /srv/www/$pkg
        exit 1
    }

    mv /srv/www/$pkg /srv/www/bugzilla
}

ensure_service_started postgresql postgres


[ -z "$CONF_CHANGED" ] || service apache2 restart

ensure_service_started apache2 apache2

