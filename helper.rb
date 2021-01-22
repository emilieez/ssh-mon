CONFIG_FILE = "ssh_mon_config"
AUTH_LOG = "auth.log"
FAILED_LOG = "failed_auth.log"
IP_LOGS_DIR = "ip_logs"

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

def get_log_line_number(time)
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

def extract_ip_from_line(line)
    return line.scan(/[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}/).first
end
