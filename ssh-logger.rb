#!/usr/bin/env ruby
require 'fileutils'
require_relative "helper.rb"

CURRENT_TIME = "Jan 21 07:15:03"
# CURRENT_TIME = Time.now.strftime("%b %d %H:%M:%S")

ENABLE_SSH_MONITOR = get_value_from_file(CONFIG_FILE, "ENABLE_SSH_MONITOR").freeze
MAX_ATTEMPTS = get_value_from_file(CONFIG_FILE, "MAX_ATTEMPTS").to_i.freeze
LOCK_TIME = get_value_from_file(CONFIG_FILE, "LOCK_TIME").freeze

if ENABLE_SSH_MONITOR == "true"
    current_fail_line = get_current_fail_line()

    append_to_file(FAILED_LOG, current_fail_line)
    sender_ip = extract_ip_from_line(current_fail_line)

    sender_logs = "#{IP_LOGS_DIR}/#{sender_ip}"
    FileUtils.mkdir(IP_LOGS_DIR) unless Dir.exists?(IP_LOGS_DIR)
    if File.exists?(sender_logs)
        current_attempts = get_value_from_file(sender_logs, "CURRENT_ATTEMPTS").to_i
        last_attempt_time = get_value_from_file(sender_logs, "LAST_ATTEMPT_TIME")

        if current_attempts >= MAX_ATTEMPTS
            puts "BLOCK IP"
            exit(1)
        else
            current_attempts += 1
            update_value_in_file(sender_logs, "CURRENT_ATTEMPTS", current_attempts)
            update_value_in_file(sender_logs, "LAST_ATTEMPT_TIME", CURRENT_TIME) 
        end
    else
        write_to_sender_log(sender_logs, 1, CURRENT_TIME)
    end
else
    exit(0)
end

