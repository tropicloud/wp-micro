wpm_wp_install() {

	wpm_header "WordPress Install"
	
	# ------------------------
	# NGINX
	# ------------------------
	
	if [[  $WP_SSL == 'true'  ]];
	then WP_URL="https://${HOSTNAME}" && cat /wpm/etc/nginx/wpssl.conf | sed -e "s/example.com/$HOSTNAME/g" > /etc/wpm/nginx.conf && wpm_ssl $HOSTNAME
	else WP_URL="http://${HOSTNAME}" && cat /wpm/etc/nginx/wp.conf | sed -e "s/example.com/$HOSTNAME/g" > /etc/wpm/nginx.conf
	fi

	# ------------------------
	# PHP-FPM
	# ------------------------
	
	if [[  $(free -m | grep 'Mem' | awk '{print $2}') -gt 1800  ]];
	then cat /wpm/etc/php/php-fpm.conf > /etc/php/php-fpm.conf
	else cat /wpm/etc/php/php-fpm-min.conf > /etc/php/php-fpm.conf
	fi
	
	# ------------------------
	# WORDPRESS
	# ------------------------
	

	su -l $user -c "cd /var/wpm && git clone $WP_REPO ."
	su -l $user -c "cd /var/wpm && composer install && ln -s /var/wpm/web ~/"

	if [[  ! -f /var/www/web/.env   ]]; then wpm_env; fi
	
	if [[  -n "$WP_URL" && -n "$WP_TITLE" && -n "$WP_USER" && -n "$WP_MAIL" && -n "$WP_PASS"  ]] ; then
		su -l $user -c "cd /var/wpm/web && wp core install --url=${WP_URL} --title=${WP_TITLE} --admin_name=${WP_USER} --admin_email=${WP_MAIL} --admin_password=${WP_PASS}"
	fi
}
