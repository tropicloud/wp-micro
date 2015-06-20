# ------------------------
# WPM START
# ------------------------

wpm_start() {	

	if [[  ! -d /var/lib/mysql  ]]; then wpm_mysql_setup; fi
	if [[  ! -d /var/wpm/web  ]]; then wpm_wp_setup; fi

	wpm_header "Startup"

	if [[  ! -z $MEMCACHE_PORT || ! -z $REDIS_PORT  ]]; then
		if [[  ! -z $REDIS_PORT  ]]; then echo -e "  Redis listening @ $WPM_REDIS"; fi
		if [[  ! -z $MEMCACHE_PORT  ]]; then echo -e "  Memcached listening @ $WPM_MEMCACHE \n"; fi
	fi
	
	if [[  -f /tmp/supervisord.pid  ]]; then
	
		if [[  -z $2  ]];
		then /usr/bin/supervisorctl start all;
		else /usr/bin/supervisorctl start $2;
		fi

	else exec /usr/bin/supervisord -n -c /etc/supervisord.conf	
	fi
}

# ------------------------
# WPM STOP
# ------------------------

wpm_stop() {

	wpm_header "Stop"

	if [[  -f /tmp/supervisord.pid  ]]; then
	
		if [[  -z $2  ]];
		then /usr/bin/supervisorctl stop all;
		else /usr/bin/supervisorctl stop $2;
		fi
	
	fi
}

# ------------------------
# WPM RESTART
# ------------------------

wpm_restart() {
	
	wpm_header "Restart"

	if [[  -f /tmp/supervisord.pid  ]]; then
	
		if [[  -z $2  ]];
		then /usr/bin/supervisorctl restart all;
		else /usr/bin/supervisorctl restart $2;
		fi
		
	else exec /usr/bin/supervisord -n -c /etc/supervisord.conf;
	fi
}

# ------------------------
# WPM RELOAD
# ------------------------

wpm_reload() {

	wpm_header "Reload"

	if [[  -f /tmp/supervisord.pid  ]];
	then /usr/bin/supervisorctl reload;
	fi
}

# ------------------------
# WPM SHUTDOWN
# ------------------------

wpm_shutdown() {

	wpm_header "Shutdown"

	if [[  -f /tmp/supervisord.pid  ]];
	then /usr/bin/supervisorctl shutdown;
	fi
}

# ------------------------
# WPM STATUS
# ------------------------

wpm_status() {
	
	wpm_header "Status"

	if [[  -f /tmp/supervisord.pid  ]]; then
	
		if [[  -z $2  ]];
		then /usr/bin/supervisorctl status all;
		else /usr/bin/supervisorctl status $2;
		fi
	
	fi
}

# ------------------------
# WPM LOG
# ------------------------

wpm_log() {

	wpm_header "Log"
	
	if [[  -f /tmp/supervisord.pid  ]];
	then /usr/bin/supervisorctl maintail;
	fi
}

# ------------------------
# WPM LOGIN
# ------------------------

wpm_login() {

	wpm_header "\033[0mLogged in as \033[1;37m$user\033[0m"
	su -l $user;
}

# ------------------------
# WPM ROOT
# ------------------------

wpm_root() {

	wpm_header "\033[0mLogged in as \033[1;37mroot\033[0m"
 	/bin/sh 	
}
