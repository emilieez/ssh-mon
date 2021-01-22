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

def create_sshmon_config(max_attempts, lock_time, bookmark)
    File.open(CONFIG_FILE, 'w') { |file|
        config = [
            "MAX_ATTEMPTS=#{max_attempts}",
            "LOCK_TIME=#{lock_time}",
            "LOG_BOOKMARK=#{bookmark}"
        ]
        file.write(config.join("\n"))
    }
end

def get_most_recent_fail(current_time)
    line_num = get_new_log_bookmark(current_time) # line num of the most recent fail
    auth_log_line = `sed -n \'#{line_num}p\' < #{AUTH_LOG}` # info/content of the most recent fail
    return {
        line_num: line_num,
        log_content: auth_log_line
    }
end

def create_sender_logfile (log_file, num_of_attempts, last_attempt_time)
    File.open(log_file, 'w') { |file|
        info = [
            "CURRENT_ATTEMPTS=#{num_of_attempts}",
            "LAST_ATTEMPT_TIME=#{last_attempt_time}"
        ]
        file.write(info.join("\n"))
    }
end