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

def update_value_in_file(file, key, new_value) 
    system("sed -i \'s/#{key}=.*/#{key}=#{new_value}/g\' #{file}")
end

def remove_whitespace(string)
    return string.to_s.gsub(/\s+/,"")
end

def get_new_log_bookmark(time)
    log_bookmark = get_value_from_file(CONFIG_FILE, "LOG_BOOKMARK").gsub(/\s+/,"").to_i
   
    if log_bookmark == 0
        # Look in the entire log file to find logs after monitor started
        log_bookmark = `awk \'/#{time}/{ print NR; exit }\' #{AUTH_LOG}`
        log_bookmark = remove_whitespace(log_bookmark).to_i
    end

    # Only look in the content after log bookmark
    line_offset = `tail -n +#{log_bookmark} #{AUTH_LOG} | awk '/Failed password/{ print NR; exit }'`
    new_log_bookmark = log_bookmark + line_offset.to_i - 1
      
    new_log_bookmark = remove_whitespace(new_log_bookmark).to_i
    update_value_in_file(CONFIG_FILE, "LOG_BOOKMARK", new_log_bookmark)
    return new_log_bookmark
end

def extract_ip_from_line(line)
    return line.scan(/[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}/).first
end
