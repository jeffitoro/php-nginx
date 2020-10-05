#!/bin/bash
service nginx start && php-fpm ; while true ; do sleep 100; done;
cd /var/www && chown www-data: . -R 
