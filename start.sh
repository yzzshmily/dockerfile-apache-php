#!/bin/bash
set -e

# Apache gets grumpy about PID files pre-existing
rm -f /usr/local/apache/logs/httpd.pid
/usr/local/apache/bin/apachectl -D FOREGROUND -k start
