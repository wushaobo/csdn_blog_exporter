require 'fileutils'

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
      save_to_file article, dir
    end
  end
  
  private
  
  def create_folder
    FileUtils.rm_rf @author
    Dir.mkdir @author
    Dir.chdir @author
    Dir.pwd
  end
  
  def save_to_file article, dir
    puts "[Saving]  #{article.to_s}"
    begin
      Dir.chdir dir
      file = File.new("#{article.to_s}.html", 'w')
      file.write html_template(article)
      file.close
      puts "[Done]"
    rescue
      puts "[Failed]"
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
