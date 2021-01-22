#!/usr/bin/env ruby

require 'fileutils'
require_relative "helper.rb"

MAX_ATTEMPTS = get_value_from_file(CONFIG_FILE, "MAX_ATTEMPTS").to_i.freeze
LOCK_TIME = get_value_from_file(CONFIG_FILE, "LOCK_TIME").to_i.freeze

sender_ip = ARGV[0]
current_time = ARGV[1]

def create_sender_logfile (log_file, num_of_attempts, last_attempt_time)
    File.open(log_file, 'w') { |file|
        info = [
            "CURRENT_ATTEMPTS=#{num_of_attempts}",
            "LAST_ATTEMPT_TIME=#{last_attempt_time}"
        ]
        file.write(info.join("\n"))
    }
end

# Save number of login attempts and time of last attempt of a specific IP to a textfile named <ipaddr>"
# Save the textfile for each IP to a single directory
sender_logs = "#{IP_LOGS_DIR}/#{sender_ip}"
FileUtils.mkdir(IP_LOGS_DIR) unless Dir.exists?(IP_LOGS_DIR)

if File.exists?(sender_logs)
    current_attempts = get_value_from_file(sender_logs, "CURRENT_ATTEMPTS").to_i
    last_attempt_time = get_value_from_file(sender_logs, "LAST_ATTEMPT_TIME")

    if current_attempts >= MAX_ATTEMPTS
        puts "BLOCK IP" #TODO: add firewall block scripts here
        FileUtils.rm(sender_logs) # reset sender logs
        exit(1)
    else
        current_attempts += 1
        update_value_in_file(sender_logs, "CURRENT_ATTEMPTS", current_attempts)
        update_value_in_file(sender_logs, "LAST_ATTEMPT_TIME", current_time) 
    end
else
    # Create the sender_log file:
    #   CURRENT_ATTEMPTS=1
    #   LAST_ATTEMPT_TIME=<CURRENT TIME>
    create_sender_logfile(sender_logs, 1, current_time)
end
