require 'open-uri'

#settings
YOUR_ID = 'example@example.com'
YOUR_PW = '01234567890'

#get paths
file_path = Dir::pwd() + '/data_urls.txt'
url_base = "http://tcserv.nii.ac.jp/access/#{YOUR_ID}/#{YOUR_PW}/nicocomm/data/video"
download_path_base = "#{Dir::pwd}/download"

#open list file and download
open(file_path, 'r').each_line do |file_name|
  download_path = "#{download_path_base}/#{file_name.chomp!}"
  next if FileTest.exists?(download_path)
  open(download_path, 'wb') do |output|
    open("#{url_base}/#{file_name}") do |data|
      output.write(data.read)
    end
  end
end