#!/usr/bin/env ruby

require 'fileutils'
require_relative "../lib/presets.rb"
require_relative "../lib/texts_helper.rb"

if File.exists?(CONFIG_FILE)
    MAX_ATTEMPTS = get_value_from_file(CONFIG_FILE, "MAX_ATTEMPTS").to_i.freeze

    sender_ip = ENV['PAM_RHOST']
    current_time = Time.now.strftime("%b %d %H:%M:%S") 

    # Save number of login attempts and time of last attempt of a specific IP to a textfile named <ipaddr>"
    # Save the textfile for each IP to a single directory
    sender_logs = "#{IP_LOGS_DIR}/#{sender_ip}"
    FileUtils.mkdir(IP_LOGS_DIR) unless Dir.exists?(IP_LOGS_DIR)

    if File.exists?(sender_logs)
        current_attempts = get_value_from_file(sender_logs, "CURRENT_ATTEMPTS").to_i
        last_attempt_time = get_value_from_file(sender_logs, "LAST_ATTEMPT_TIME")
	    system("sudo find #{IP_LOGS_DIR}/* -mmin +#{DEFAULT_RESET_FAILED_TIME} -exec rm {} \;)")

        if current_attempts >= MAX_ATTEMPTS
            system("ruby #{BLOCK_IP_SCRIPT} #{sender_ip} &")
            FileUtils.rm(sender_logs) # reset sender logs
            exit(1)
        else
            current_attempts += 1
            update_value_in_file(sender_logs, "CURRENT_ATTEMPTS", current_attempts)
            update_value_in_file(sender_logs, "LAST_ATTEMPT_TIME", current_time) 
        end
    else
        File.open(sender_logs, 'w') { |file|
            info = [
                "CURRENT_ATTEMPTS=1",
                "LAST_ATTEMPT_TIME=#{current_time}"
            ]
            file.write(info.join("\n"))
        }
    end
    exit(1)
else
    exit(0)
end
