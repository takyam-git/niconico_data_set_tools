require 'json'
require 'mongo'
require 'time'

#create mongo connection
mongo = Mongo::Connection.new
db = mongo.db('niconico')
collection = db.collection('videos')
complete_files = db.collection('complete_files')

Dir::entries(path_base = Dir::pwd+'/download').each do |file_name|
  next if !(file_name =~ /\.gz$/)
  path = path_base + '/' + file_name
  if complete_files.find(:file_path => path).to_a.size <= 0
    Zlib::GzipReader.open(path) do |gz|
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
      complete_files.insert({:file_path => path})
    end
  end
end