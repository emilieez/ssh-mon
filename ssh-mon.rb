#!/usr/local/bin/ruby

require 'optparse'
require_relative 'helper.rb'

DEFAULT_MAX_ATTEMPT = 3
DEFAULT_LOCK_TIME = 5

options = {
    attempt: DEFAULT_MAX_ATTEMPT,
    time: DEFAULT_LOCK_TIME
}

def update_sshmon_config(max_attempts, lock_time, bookmark)
    update_value_in_file(CONFIG_FILE, "MAX_ATTEMPTS", max_attempts)
    update_value_in_file(CONFIG_FILE, "LOCK_TIME", lock_time)
    update_value_in_file(CONFIG_FILE, "LOG_BOOKMARK", bookmark)
end

def get_most_recent_fail(current_time)
    line_num = get_new_log_bookmark(current_time) # line num of the most recent fail
    auth_log_line = `sed -n \'#{line_num}p\' < #{AUTH_LOG}` # info/content of the most recent fail
    return {
        line_num: line_num,
        log_content: auth_log_line
    }
end

OptionParser.new do |opts|
    opts.on("-a", "--attempt 3", Integer, "Max failed attempts") do |attempt|
        options[:attempt] = attempt
    end

    opts.on("-t", "--time 10", Integer, "IP Disable time") do |time|
        options[:time] = time
    end
end.parse!

update_sshmon_config(options[:attempt], options[:time], 0)

most_recent_fail = nil
# current_time = Time.now.strftime("%b %d %H:%M:%S")  
current_time = "Jan 21 07:15:03"

while true
    current_fail_line = get_most_recent_fail(current_time) # Get the log for current failed attempt
    
    if !current_fail_line.empty? && !current_fail_line.nil? && most_recent_fail != current_fail_line[:line_num]
        puts current_fail_line[:log_content]
        sender_ip = extract_ip_from_line(current_fail_line[:log_content])
        system("ruby failed-ssh-logger.rb #{sender_ip} \"#{current_time}\"")
    end
    most_recent_fail = current_fail_line[:line_num]
end