#!/usr/local/bin/ruby

require 'optparse'
require_relative 'helper.rb'

DEFAULT_MAX_ATTEMPT = 3
DEFAULT_LOCK_TIME = 5

options = {
    attempt: DEFAULT_MAX_ATTEMPT,
    time: DEFAULT_LOCK_TIME
}

def update_sshmon_config(enable, max_attempts, lock_time, bookmark)
    update_value_in_file(CONFIG_FILE, "ENABLE_SSH_MONITOR", enable)
    update_value_in_file(CONFIG_FILE, "MAX_ATTEMPTS", max_attempts)
    update_value_in_file(CONFIG_FILE, "LOCK_TIME", lock_time)
    update_value_in_file(CONFIG_FILE, "LOG_BOOKMARK", bookmark)
end

OptionParser.new do |opts|
    opts.on("-a", "--attempt 3", Integer, "Max failed attempts") do |attempt|
        options[:attempt] = attempt
    end

    opts.on("-t", "--time 10", Integer, "IP Disable time") do |time|
        options[:time] = time
    end
end.parse!

update_sshmon_config("true", options[:attempt], options[:time], 0)
until (input = gets.chomp) == 'q' || (input = gets.chomp) == 'Q'
    sleep()
end

update_sshmon_config("false", DEFAULT_MAX_ATTEMPT, DEFAULT_LOCK_TIME, 0)
exit()