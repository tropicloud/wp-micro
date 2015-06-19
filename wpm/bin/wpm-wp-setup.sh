wpm_wp_install() {

	mysqld_safe > /dev/null 2>&1 &
	while [[  ! -e /run/mysqld/mysqld.sock  ]]; do sleep 1; done
	
	cd /var/wpm/web
	wp core install --allow-root --url=$WP_HOME --title=$WP_TITLE --admin_name=$WP_USER --admin_email=$WP_MAIL --admin_password=$WP_PASS
	
	mysqladmin -u root shutdown

}

wpm_wp_setup() {

	wpm_header "WordPress Setup"
	
	# ------------------------
	# NGINX
	# ------------------------
	
	if [[  $WP_SSL == 'true'  ]];
	then WP_URL="https://${HOSTNAME}" && cat /wpm/etc/nginx/wpssl.conf | sed -e "s/example.com/$HOSTNAME/g" > /etc/wpm/wordpress.conf
	else WP_URL="http://${HOSTNAME}" && cat /wpm/etc/nginx/wp.conf | sed -e "s/example.com/$HOSTNAME/g" > /etc/wpm/wordpress.conf
	fi

	# ------------------------
	# PHP-FPM
	# ------------------------
	
	if [[  $(free -m | grep 'Mem' | awk '{print $2}') -gt 1800  ]];
	then cat /wpm/etc/php/php-fpm.conf > /etc/wpm/php-fpm.conf
	else cat /wpm/etc/php/php-fpm-min.conf > /etc/wpm/php-fpm.conf
	fi
	
	# ------------------------
	# WORDPRESS
	# ------------------------
	
	su -l $user -c "cd /var/wpm && git clone $WP_REPO ."
	su -l $user -c "cd /var/wpm && composer install"
	su -l $user -c "ln -s /var/wpm/web ~/"

	if [[  ! -f /var/wpm/.env   ]]; then wpm_env && . /var/wpm/.env; fi	

	if [[  -n "$WP_TITLE" && -n "$WP_USER" && -n "$WP_MAIL" && -n "$WP_PASS"  ]]; then wpm_wp_install; fi
	
	wpm_ssl $HOSTNAME
}