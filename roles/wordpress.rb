name 'wordpress'
description 'This role configures a WordPress stack with PHP-FPM'
default_attributes(:bluepill => {:bin => "/usr/local/bin/bluepill"})
run_list "recipe[apt]", "recipe[build-essential]", "recipe[percona_mysql]", "recipe[packages]", "recipe[sudo]", "recipe[bluepill]", "recipe[nginx]", "recipe[php]", "recipe[wordpress]", "recipe[wordpress::databases]", "recipe[haproxy]", "recipe[git]", "recipe[ssh_deploy_keys]"