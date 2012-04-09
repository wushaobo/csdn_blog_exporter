require File.expand_path(File.join(File.dirname(__FILE__), '..', 'helpers/helper.rb'))
require File.expand_path(File.join(File.dirname(__FILE__), '..', 'models/article.rb'))
require File.expand_path(File.join(File.dirname(__FILE__), '..', 'models/article_list.rb'))

namespace :blog do
  include Helper
  
  desc "fetch all article from the blog"
  task :fetch, :author do |t, args|
    author = args[:author]
    unless author
      raise "rake blog:fetch[author] # Invalid command. Please provide the author name."
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

