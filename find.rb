require 'metainspector'
require 'net/smtp'

KIJIJI_CACHE = "#{ENV['ROOTDIR']}/.cached_miata_links_kijiji".freeze

page = MetaInspector.new('https://www.kijiji.ca/b-cars-trucks/ontario/convertible-mazda-new__used/c174l9004a138a54a49?price=5000__16000&transmission=1')
current_miata_links = page.links.http.select do |a|
  a.start_with?('https://www.kijiji.ca/v-cars-trucks/') && a.include?('mazda') && !a.match?(/\?imageNumber=*/)
end
previous_miata_links = []
previous_miata_links = Marshal.load(File.binread(KIJIJI_CACHE)) if File.exist?(KIJIJI_CACHE)
new_miata_links = current_miata_links - previous_miata_links
File.open(KIJIJI_CACHE, 'wb') {|f| f.write(Marshal.dump(current_miata_links))}
return puts "No new miatas found #{Time.now}" if new_miata_links.empty?

date = Time.now.strftime('on %m/%d/%Y at %I:%M%p')
mail = <<-MAIL
From: #{ENV['MAILFROM']}
To: #{ENV['MAILTO']}
Subject: New Miata Posted #{date}

#{new_miata_links.join("\n")}
MAIL

Net::SMTP.start('smtp.gmail.com', 587, 'gmail.com', ENV['MAILFROM'], ENV['MAILPASSWD'], :plain) do |smtp|
  smtp.send_message(mail, ENV['MAILFROM'], ENV['MAILTO'])
end

puts "Sucessfully sent email at #{date}"
