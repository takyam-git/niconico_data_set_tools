require 'open-uri'
require 'json'
require 'mongo'
require 'time'

#settings
YOUR_ID = 'example@example.com'
YOUR_PW = '01234567890'

#create mongo connection
mongo = Mongo::Connection.new
db = mongo.db('niconico')
collection = db.collection('videos')
complete_files = db.collection('complete_files')

#get paths
file_path = Dir::pwd() + '/data_urls.txt'
url_base = "http://tcserv.nii.ac.jp/access/#{YOUR_ID}/#{YOUR_PW}/nicocomm/data/video"
download_path_base = "#{Dir::pwd}/download"

#open list file and download
open(file_path, 'r').each_line do |file_name|

  #ダウンロード先のパスを設定
  download_path = "#{download_path_base}/#{file_name.chomp!}"

  #ファイル名がgzじゃなかったり既に処理済みだったらスキップ
  if !(file_name =~ /\.gz$/)
    puts "#{file_name} is not correct file name."
    next
  elsif complete_files.find(:file_path => download_path).to_a.size > 0
    puts "#{file_name} is completed yet. skip!"
    next
  end

  #ファイルがまだDLされていなければDLする
  if !(FileTest.exists?(download_path))
    puts "#{file_name} download start..."
    open(download_path, 'wb') do |output|
      open("#{url_base}/#{file_name}") do |data|
        output.write(data.read)
        puts "#{file_name} save success!"
      end
    end
  end

  #DLしたファイルを読み込んで処理する
  Zlib::GzipReader.open(download_path) do |gz|
    puts "#{file_name} start read and insert."
    #read gzip
    gz = gz.read.split(/\r\n|\n\r|\n|\r/)
    gz.each do |json|
      #parse json and date to Time object
      video_data = JSON.parse(json)
      video_data["upload_time"] = Time.parse(video_data["upload_time"])

      #update or insert
      collection.find_and_modify({
        :update => video_data,
        :query => {
          :video_id => video_data["video_id"],
          :thread_id => video_data["thread_id"],
        },
        :upsert => true,
      })
    end
    #add complete flag
    complete_files.insert({:file_path => download_path})
    puts "#{file_name} success!"

    #delete gz file
    File.delete(download_path) if FileTest.exists?(download_path)
    puts "#{file_name} complete!"
  end
end