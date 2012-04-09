require 'open-uri'
require 'nokogiri'

module Helper
  def root
    "http://blog.csdn.net"
  end
  
  def html_document url
    puts "opening #{url}"
    content = open(url).read
    Nokogiri::HTML(content, nil, "UTF-8")
  end
end