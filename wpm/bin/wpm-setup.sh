
wpm_version(){

	WP_VER=`cat $wpm/composer.json | grep 'johnpbloch/wordpress' | cut -d: -f2`
	
	if [[  ! -z $WP_VERSION  ]];
	then sed -i "s/$WP_VER/\"$WP_VERSION\"/g" $wpm/composer.json && su -l $user -c "cd $wpm && composer update"
	fi
}

wpm_setup() {

# NGINX
# ---------------------------------------------------------------------------------

	cat /wpm/etc/init.d/nginx.ini | sed -e "s/example.com/$HOSTNAME/g" > $home/init.d/nginx.ini
	cat /wpm/etc/nginx/nginx.conf | sed -e "s/example.com/$HOSTNAME/g" > /etc/nginx/nginx.conf
	
	if [[  $WP_SSL == 'true'  ]];
	then cat /wpm/etc/nginx/wpssl.conf | sed -e "s/example.com/$HOSTNAME/g" > $home/conf.d/nginx.conf && wpm_ssl
	else cat /wpm/etc/nginx/wp.conf | sed -e "s/example.com/$HOSTNAME/g" > $home/conf.d/nginx.conf
	fi
	

# PHP
# ---------------------------------------------------------------------------------
	
	cat /wpm/etc/init.d/php-fpm.ini | sed -e "s/example.com/$HOSTNAME/g" > $home/init.d/php-fpm.ini

	if [[  $(free -m | grep 'Mem' | awk '{print $2}') -gt 1800  ]];
	then cat /wpm/etc/php/php-fpm.conf | sed -e "s/example.com/$HOSTNAME/g" > $home/conf.d/php-fpm.conf
	else cat /wpm/etc/php/php-fpm-min.conf | sed -e "s/example.com/$HOSTNAME/g" > $home/conf.d/php-fpm.conf
	fi


# MYSQL
# ---------------------------------------------------------------------------------
	
	if [[  -z $MYSQL_PORT  ]]; then wpm_mysql_setup; else wpm_mysql_link; fi
	
	
# MSMTP
# ---------------------------------------------------------------------------------

	cat /wpm/etc/smtp/msmtprc | sed -e "s/example.com/$HOSTNAME/g" > /etc/msmtprc
	echo "sendmail_path = /usr/bin/msmtp -t" > /etc/php/conf.d/sendmail.ini
	touch /var/log/msmtp.log
	chmod 777 /var/log/msmtp.log


# SUPERVISOR
# ---------------------------------------------------------------------------------
	
	cat /wpm/etc/supervisord.conf \
	| sed -e "s/example.com/$HOSTNAME/g" \
	| sed -e "s/WPM_ENV_HTTP_PASS/{SHA}$WPM_ENV_HTTP_SHA1/g" \
	> /etc/supervisord.conf && chmod 644 /etc/supervisord.conf


# WORDPRESS
# ---------------------------------------------------------------------------------
	
	wpm_header "WordPress Setup"
	
	su -l $user -c "git clone $WP_REPO wpm" && wpm_version
	su -l $user -c "cd $wpm && composer install"

	wpm_wp_install > $home/log/wpm-wordpress.log 2>&1 & 			
	wpm_wp_status() { cat $home/log/wpm-install.log | grep -q "WordPress setup completed"; }
		
	echo -ne "Installing WordPress..."
	while ! wpm_wp_status true; do echo -n '.'; sleep 1; done; echo -ne " done.\n"
	
	s="" && q=`cat $home/log/wpm-wordpress.log | grep -q "$s"`	
	s="Plugin 'wp-ffpc' activated"; if [[  $q true  ]]; then echo $s; fi
	s="Plugin 'redis-cache' activated"; if [[  $q true  ]]; then echo $s; fi
	s="WordPress installed successfully"; if [[  $q true  ]]; then echo $s; fi
}
