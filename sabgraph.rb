require 'simple-rss'
require 'open-uri'
require 'googlecharts'

def format_speed(number, unit)
  if unit == "MB/s"
    number = number * 1024
  end
  return number
end

# Verify arguments. Show usage and exit on failure
unless ARGV.length == 4
  puts "Usage: ruby #{$0} ip port username password\n"
  exit
end

data = []
begin
  rss = SimpleRSS.parse open("http://#{ARGV[0]}:#{ARGV[1]}/rss?mode=history&ma_username=#{ARGV[2]}&ma_password=#{ARGV[3]}&limit=20000")

  # I'm not sure why some items have a nil description, but filter them out, since we can't read their speed
  rss.items.select{|x| !x.description.nil? }.sort{|x,y| x.pubDate <=> y.pubDate }.each do |i|
    line = i.description.scan(/Downloaded in .* at an average of (.*)([mk]b\/s)/i).first
    speed = format_speed(line[0].to_f, line[1])
    data << speed
  end
rescue
  puts "Download of the RSS feed failed. Verify your host details and credentials are correct."
end

chart = Gchart.line(:size => '600x400',
            :title => "Speed over time in KB/s",
            :bg => 'efefef',
            :legend => ['Speed'],
            :data => data)

puts chart
