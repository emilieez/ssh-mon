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