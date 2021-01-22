# For each IP:
#   store last attempt timestamp, number of valid failed attempts

#!/usr/bin/env ruby

CONFIG_FILE = "ssh_mon_config"
AUTH_LOG = "auth.log"
FAILED_LOG = "failed_auth.log"

CURRENT_TIME = "Jan 21 07:15:03"
# CURRENT_TIME = Time.now.strftime("%b %d %H:%M:%S")

def get_value_from_file (file, key)
    value = File.read(file).match(/^#{key}=(.*)$/)
    if (!value.nil? && value.length > 0)
        value = value[1].strip
    end

    return (value.nil? || value.empty?) ? nil : value 
end

def write_to_sender_log (log_file, num_of_attempts, last_attempt_time)
    File.open(log_file, 'w') { |file|
        info = [
            "CURRENT_ATTEMPTS=#{num_of_attempts}",
            "LAST_ATTEMPT_TIME=#{CURRENT_TIME}"
        ]
        file.write(info.join("\n"))
    }
end

def save_log_bookmark (log_line_number)
    system("sed -i \'s/LOG_BOOKMARK=.*/LOG_BOOKMARK=#{log_line_number}/g\' #{CONFIG_FILE}")
end

ENABLE_SSH_MONITOR = get_value_from_file(CONFIG_FILE, "ENABLE_SSH_MONITOR")
MAX_ATTEMPTS = get_value_from_file(CONFIG_FILE, "MAX_ATTEMPTS").to_i
LOCK_TIME = get_value_from_file(CONFIG_FILE, "LOCK_TIME")

if ENABLE_SSH_MONITOR == "true"

    log_bookmark = get_value_from_file(CONFIG_FILE, "LOG_BOOKMARK").gsub(/\s+/,"").to_i
    if log_bookmark >= 1
        line_offset = `tail -n +#{log_bookmark} #{AUTH_LOG} | awk '/#{CURRENT_TIME}/{ print NR; exit }'`
        log_line_number = log_bookmark + line_offset.to_i
        save_log_bookmark(log_line_number)
    else
        log_line_number = `awk \'/#{CURRENT_TIME}/{ print NR; exit }\' #{AUTH_LOG}`
        log_line_number = log_line_number.gsub(/\s+/,"")
        save_log_bookmark(log_line_number)
    end
    auth_log_line = `tail -n +#{log_line_number} #{AUTH_LOG} | grep -a -m 1 -h 'Failed password'`
    
    # File.open(FAILED_LOG, 'a+') { |file|
    #     file.puts auth_log_line
    # }

    sender_ip = auth_log_line.scan(/[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}/).first
    sender_logs = "ip_logs/#{sender_ip}"
    if File.exists?(sender_logs)
        current_attempts = get_value_from_file(sender_logs, "CURRENT_ATTEMPTS").to_i
        last_attempt_time = get_value_from_file(sender_logs, "LAST_ATTEMPT_TIME")

        if current_attempts >= MAX_ATTEMPTS
            puts "BLOCK IP"
            exit(1)
        else
            current_attempts += 1
            write_to_sender_log(sender_logs, current_attempts, CURRENT_TIME)
        end
    else
        write_to_sender_log(sender_logs, 1, CURRENT_TIME)
    end
else
    exit(0)
end

