#!/usr/bin/env ruby
require_relative "../lib/presets.rb"
require_relative "../lib/texts_helper.rb"

sender_ip = ARGV[0]
LOCK_TIME = get_value_from_file(CONFIG_FILE, "LOCK_TIME")

system("sudo iptables -A INPUT -s #{sender_ip} -j DROP")
system("sudo echo \"\nBlocking #{sender_ip} for #{LOCK_TIME} seconds ...\" >> #{IPTABLES_LOG}")

if !LOCK_TIME.nil? && !LOCK_TIME.empty?
    sleep(LOCK_TIME.to_i) 

    system("sudo iptables -D INPUT -s #{sender_ip} -j DROP")
    system("sudo echo \"Unblocking #{sender_ip} ...\" >> #{IPTABLES_LOG}")
    system("sudo rm #{IP_LOGS_DIR}/#{sender_ip}") if File.exists?(" #{IP_LOGS_DIR}/#{sender_ip}")
else
    exit(0)
end
