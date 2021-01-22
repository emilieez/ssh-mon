#!/usr/bin/env ruby

require 'fileutils'
require_relative "helper.rb"

CURRENT_TIME = "Jan 21 07:15:03"
# CURRENT_TIME = Time.now.strftime("%b %d %H:%M:%S")

ENABLE_SSH_MONITOR = get_value_from_file(CONFIG_FILE, "ENABLE_SSH_MONITOR").freeze
MAX_ATTEMPTS = get_value_from_file(CONFIG_FILE, "MAX_ATTEMPTS").to_i.freeze
LOCK_TIME = get_value_from_file(CONFIG_FILE, "LOCK_TIME").to_i.freeze

def get_current_fail_line
    starting_line = get_current_time_linenum_in_log(CURRENT_TIME)
    auth_log_line = `tail -n +#{starting_line} #{AUTH_LOG} | grep -a -m 1 -h 'Failed password'`
    return auth_log_line
end

def create_sender_logfile (log_file, num_of_attempts, last_attempt_time)
    File.open(log_file, 'w') { |file|
        info = [
            "CURRENT_ATTEMPTS=#{num_of_attempts}",
            "LAST_ATTEMPT_TIME=#{CURRENT_TIME}"
        ]
        file.write(info.join("\n"))
    }
end

if ENABLE_SSH_MONITOR == "true"

    current_fail_line = get_current_fail_line() # Get the log for current failed attempt
    sender_ip = extract_ip_from_line(current_fail_line)

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
            update_value_in_file(sender_logs, "LAST_ATTEMPT_TIME", CURRENT_TIME) 
        end
    else
        # Create the sender_log file:
        #   CURRENT_ATTEMPTS=1
        #   LAST_ATTEMPT_TIME=<CURRENT TIME>
        create_sender_logfile(sender_logs, 1, CURRENT_TIME)
    end
else
    exit(0)
end

