#!/usr/bin/env ruby
require_relative "lib/presets.rb"
require_relative "lib/texts_helper.rb"

sender_ip = ARGV[0]
LOCK_TIME = get_value_from_file(CONFIG_FILE, "LOCK_TIME").to_i.freeze

system("sudo iptables -A INPUT -s #{sender_ip} -j DROP")
system("sudo echo \"\nBlocking #{sender_ip} for #{LOCK_TIME} seconds ...\" >> #{IPTABLES_LOG}")

sleep(LOCK_TIME)

system("sudo iptables -D INPUT -s #{sender_ip} -j DROP")
system("sudo echo \"Unblocking #{sender_ip} ...\" >> #{IPTABLES_LOG}")

exit(0)
