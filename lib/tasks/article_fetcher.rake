require 'ap'
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
  
  def valid?
    title && url && content
  end

  private
  def fetch_content
    doc = html_document "#{root}#{url}"
    doc.search('#article_content').inner_html
  end
end

class ArticleList
  def initialize
    @articles = []
  end
  
  def add article
    @articles << article if article.valid?
  end
  
  def show
    puts "#{@articles.size} articles in total:"
    @articles.collect do |article|
      puts "  #{article.title}"
    end
  end
end

namespace :article_fetcher do
  include Helper
  
  desc "fetch all article from the blog"
  task :blog do
    page_index = 1
    begin
      page = html_document article_list_page_url(page_index)
      collect_articles page
      page_index = page_index.next
    end while page_index <= last_page_index(page)
    
    article_list.show
  end
  
  def article_list_page_url page_index
    "#{root}/shaobo_wu/article/list/#{page_index}"
  end
  
  def last_page_index doc
    return @last_page_index unless @last_page_index.nil?
    last_page_url = doc.css(".pagelist a:contains('尾页')").first.attributes["href"].value
    @last_page_index = last_page_url.split('/').last.to_i
  end
  
  def collect_articles doc
    doc.css('h3 a').each do |link|
      title = link.content.strip
      url = link.attributes["href"].value
      article_list.add(Article.new(title, url))
    end
  end
  
  def article_list
    @article_list ||= ArticleList.new
  end
end

