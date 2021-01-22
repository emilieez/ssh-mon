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

def update_value_in_file(file, key, new_value) 
    system("sed -i \'s/#{key}=.*/#{key}=#{new_value}/g\' #{file}")
end

def remove_whitespace(string)
    return string.to_s.gsub(/\s+/,"")
end

def get_log_line_number
    log_bookmark = get_value_from_file(CONFIG_FILE, "LOG_BOOKMARK").gsub(/\s+/,"").to_i
    if log_bookmark >= 1
        line_offset = `tail -n +#{log_bookmark} #{AUTH_LOG} | awk '/#{CURRENT_TIME}/{ print NR; exit }'`
        log_line_number = log_bookmark + line_offset.to_i
    else
        log_line_number = `awk \'/#{CURRENT_TIME}/{ print NR; exit }\' #{AUTH_LOG}`
    end

    log_line_number = remove_whitespace(log_line_number)
    update_value_in_file(CONFIG_FILE, "LOG_BOOKMARK", log_line_number)
    return log_line_number
end

def append_to_file(filename, line)
    File.open(filename, 'a+') { |file|
        file.puts line
    }
end

def get_current_fail_line
    starting_line = get_log_line_number()
    auth_log_line = `tail -n +#{starting_line} #{AUTH_LOG} | grep -a -m 1 -h 'Failed password'`
    return auth_log_line
end

def extract_ip(line)
    return line.scan(/[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}/).first
end

ENABLE_SSH_MONITOR = get_value_from_file(CONFIG_FILE, "ENABLE_SSH_MONITOR").freeze
MAX_ATTEMPTS = get_value_from_file(CONFIG_FILE, "MAX_ATTEMPTS").to_i.freeze
LOCK_TIME = get_value_from_file(CONFIG_FILE, "LOCK_TIME").freeze

if ENABLE_SSH_MONITOR == "true"
    current_fail_line = get_current_fail_line()

    append_to_file(FAILED_LOG, current_fail_line)
    sender_ip = extract_ip(current_fail_line)

    sender_logs = "ip_logs/#{sender_ip}"
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

