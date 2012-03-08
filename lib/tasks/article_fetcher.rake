require 'ap'
require 'open-uri'
require 'nokogiri'

module Helper
  def root
    "http://blog.csdn.net"
  end
  
  def document url
    puts "opening #{url}"
    content = open(url).read
    Nokogiri::HTML(content, nil, "UTF-8")
  end

  def show_all articles
    articles.each{|article| puts article}    
  end    
end

class Article
  attr_reader :title, :url, :content
  include Helper
  
  def initialize(title, url)
    @title = title
    @url = url
    @content = fetch_content
  end
  
  def to_s
    # "#{title}\n#{url}\n#{content}"
    "#{title}\n#{url}"
  end

  private
  def fetch_content
    doc = document "#{root}#{url}"
    doc.search('#article_content').inner_html
  end
end

namespace :article_fetcher do
  include Helper
  
  desc "fetch all article from the blog"
  task :blog do
    doc = document "#{root}/shaobo_wu"
    articles = doc.css('h3 a').collect do |link|
      title = link.content.strip
      url = link.attributes["href"].value
      Article.new(title, url)
    end
    show_all articles
  end
end

