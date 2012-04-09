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
