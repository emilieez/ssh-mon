#!/usr/bin/env ruby
require_relative "../lib/presets.rb"
require_relative "../lib/texts_helper.rb"

ssh_log_file = "#{IP_LOGS_DIR}/#{ENV['PAM_RHOST']}"
system("sudo rm #{ssh_log_file}") if File.exists?(ssh_log_file)
exit(0)
