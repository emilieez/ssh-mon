#!/usr/local/bin/ruby

require 'optparse'

DEFAULT_MAX_ATTEMPT = 3
DEFAULT_LOCK_TIME = 5

options = {
    attempt: DEFAULT_MAX_ATTEMPT,
    time: DEFAULT_LOCK_TIME
}

def write_to_sshmon_config(enable, max_attempts, lock_time)
    File.open("ssh_mon_config", 'w') { |file|
    config = [
        "ENABLE_SSH_MONITOR=true",
        "MAX_ATTEMPTS=#{options[:attempt]}",
        "LOCK_TIME=#{options[:time]}"
    ]
    file.write(config.join("\n"))
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

File.open("ssh_mon_config", 'w') { |file|
    config = [
        "ENABLE_SSH_MONITOR=true",
        "MAX_ATTEMPTS=#{options[:attempt]}",
        "LOCK_TIME=#{options[:time]}"
    ]
    file.write(config.join("\n"))
}

until (input = gets.chomp) == 'q' || (input = gets.chomp) == 'Q'
    sleep()
end


File.open("ssh_mon_config", 'w') { |file|
    config = [
        "ENABLE_SSH_MONITOR=false",
        "MAX_ATTEMPTS=#{DEFAULT_MAX_ATTEMPT}",
        "LOCK_TIME=#{DEFAULT_LOCK_TIME}"
    ]
    file.write(config.join("\n"))
}
exit()

# env var keep track of last failed login time