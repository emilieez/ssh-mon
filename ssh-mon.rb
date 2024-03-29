#!/usr/local/bin/ruby

require 'optparse'
require_relative "lib/presets.rb"
require_relative "lib/logging_utils.rb"
require_relative 'lib/texts_helper.rb'


options = {
    attempt: DEFAULT_MAX_ATTEMPT,
    time: DEFAULT_LOCK_TIME,
    reset: DEFAULT_RESET_FAILED_TIME
}

OptionParser.new do |opts|
    opts.on("-a", "--attempt 3", Integer, "Max failed attempts") do |attempt|
        options[:attempt] = attempt
    end

    opts.on("-t", "--time 10", Integer, "IP Disable time") do |time|
        options[:time] = time
    end
    opts.on("-r", "--reset 10", Integer, "Reset failed attempts time") do |reset|
        options[:reset] = reset
    end
end.parse!

# Reset config and IP logs directory
init_sshmon_config(options[:attempt], options[:time], options[:reset])

start_time = Time.now.strftime("%b %d %H:%M:%S") 
puts "Starting SSH Monitor at #{start_time}\n"

most_recent_fail = nil
prev_iptables_log_size = nil

while true
    current_fail_line = get_most_recent_fail(start_time) # Get the log for current failed attempt
    
    if !current_fail_line.nil? && !current_fail_line.empty? && most_recent_fail != current_fail_line[:line_num]
        puts current_fail_line[:log_content] + "\n"
        most_recent_fail = current_fail_line[:line_num]
    end

    if File.exists?(IPTABLES_LOG)
        curr_iptables_log_size = `wc -l #{IPTABLES_LOG} | awk '{ print $1 }'`
        curr_iptables_log_size = remove_whitespace(curr_iptables_log_size)
        
        if prev_iptables_log_size != curr_iptables_log_size
            puts `tail -n 1 #{IPTABLES_LOG}`
            prev_iptables_log_size = curr_iptables_log_size
        end
    end

    trap "SIGINT" do
        puts "Shutdown Application"
        exit 130
    end
end
