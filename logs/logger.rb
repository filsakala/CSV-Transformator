class Logger
  LOGFILE = "logs/log.txt"

  def self.error(message)
    File.open(LOGFILE, "a") {|file| file.puts "#{Time.now.ctime} error: #{message}\n"}
  end

  def self.info(message)
    File.open(LOGFILE, "a") {|file| file.puts "#{Time.now.ctime} info: #{message}\n"}
  end

end