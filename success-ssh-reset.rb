#!/usr/bin/env ruby
require_relative "lib/presets.rb"

ssh_log_file = "#{IP_LOGS_DIR}/#{ENV['PAM_RHOST']}"
if File.exists?(ssh_log_file)
    system("sed -i 's/CURRENT_ATTEMPTS=.*/CURRENT_ATTEMPTS=0/g' #{ssh_log_file}"
end
exit(0)
