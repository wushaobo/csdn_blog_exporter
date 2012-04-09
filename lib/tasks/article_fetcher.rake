require 'open-uri'
require 'nokogiri'
require 'fileutils'

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
  attr_reader :title, :url
  include Helper
  
  def initialize(title, url)
    @title = title
    @url = url
  end

  def content
    @content ||= document.search('#article_content').inner_html
  end
  
  def postdate
    @postdate ||= document.search('.link_postdate').text
  end
  
  def to_s
    "#{postdate}   #{title}"
  end
  
  def valid?
    title && url
  end

  private
  def document
    @doc ||= html_document "#{root}#{url}"
  end
end

class ArticleList
  def initialize author
    @author = author
    @articles = []
  end
  
  def add article
    @articles << article if article.valid?
  end
  
  # removing this method because of no usage
  def show
    puts "#{@articles.size} articles in total:"
    @articles.each do |article|
      puts "#{article.to_s}"
    end
  end
  
  def save_to_files
    dir = create_folder if @articles.size > 0
    @articles.each do |article|
      puts "saving... #{article.to_s}"
      save_to_file article, dir
    end
  end
  
  private
  
  def create_folder
    # Dir.chdir "~/downloads"
    Dir.chdir "/Users/wushaobo/Works/Ruby/nokogiri"
    FileUtils.rm_rf @author
    Dir.mkdir @author
    Dir.chdir @author
    Dir.pwd
  end
  
  def save_to_file article, dir
    begin
      Dir.chdir dir
      file = File.new("#{article.to_s}.html", 'w')
      file.write html_template(article)
      file.close
      puts "[Done] #{article.to_s}"
    rescue
      puts "[Failed] #{article.to_s}"
    end
  end
  
  def html_template article
    "<!DOCTYPE html>
    <html><body>
    <title>#{article.title}</title>
    <div>#{article.content}</div>
    </body></html>"
  end
end

namespace :article_fetcher do
  include Helper
  
  desc "fetch all article from the blog"
  task :blog, :author do |t, args|
    author = args[:author]
    unless author
      raise "rake article_fetcher:blog[author] # Invalid command. Please provide the author name."
    end
    article_list = collect_all_articles author, ArticleList.new(author)
    article_list.save_to_files
  end

  def collect_all_articles author, article_list
    page_index = 1
    begin
      doc = html_document article_list_page_url(page_index, author)
      collect_articles_in_page doc, article_list
      page_index = page_index.next
    end while page_index <= last_page_index(doc)
    article_list
  end
  
  def article_list_page_url page_index, author
    "#{root}/#{author}/article/list/#{page_index}"
  end
  
  def last_page_index doc
    return @last_page_index unless @last_page_index.nil?
    last_page_url = doc.css(".pagelist a:contains('尾页')").first.attributes["href"].value
    @last_page_index = last_page_url.split('/').last.to_i
  end
  
  def collect_articles_in_page doc, article_list
    doc.css('h3 a').each do |link|
      title = link.content.strip
      url = link.attributes["href"].value
      article_list.add(Article.new(title, url))
    end
  end
end

