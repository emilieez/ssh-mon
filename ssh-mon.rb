#!/usr/local/bin/ruby

require 'optparse'
require_relative "lib/presets.rb"
require_relative "lib/logging_utils.rb"
require_relative 'lib/texts_helper.rb'


options = {
    attempt: DEFAULT_MAX_ATTEMPT,
    time: DEFAULT_LOCK_TIME
}

OptionParser.new do |opts|
    opts.on("-a", "--attempt 3", Integer, "Max failed attempts") do |attempt|
        options[:attempt] = attempt
    end

    opts.on("-t", "--time 10", Integer, "IP Disable time") do |time|
        options[:time] = time
    end
end.parse!

# Reset config and IP logs directory
init_sshmon_config(options[:attempt], options[:time], 0)

current_time = Time.now.strftime("%b %d %H:%M:%S")  
puts "Starting SSH Monitor at #{current_time}"

most_recent_fail = nil

while true
    current_fail_line = get_most_recent_fail(current_time) # Get the log for current failed attempt
        
    if !current_fail_line.nil? && !current_fail_line.empty? && most_recent_fail != current_fail_line[:line_num]
        puts current_fail_line[:log_content]
        most_recent_fail = current_fail_line[:line_num]
    end
    sleep(5)
end
