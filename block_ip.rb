#!/usr/bin/env ruby
require_relative "lib/presets.rb"
require_relative "lib/texts_helper.rb"

sender_ip = ARGV[0]
LOCK_TIME = get_value_from_file(CONFIG_FILE, "LOCK_TIME").to_i.freeze
lock_time_seconds = LOCK_TIME * 60

system("iptables -A INPUT -s #{sender_ip} -j DROP")
system("service iptables save")

sleep(lock_time_seconds)

system("iptables -D INPUT -s #{sender_ip}-j DROP")
system("service iptables save")

exit(0)
