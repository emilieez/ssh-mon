#!/usr/bin/env ruby
require_relative "lib/presets.rb"
require_relative "lib/texts_helper.rb"

ssh_log_file = "#{IP_LOGS_DIR}/#{ENV['PAM_RHOST']}"
if File.exists?(ssh_log_file)
    update_value_in_file(ssh_log_file, CURRENT_ATTEMPTS, 0) 
end
exit(0)
