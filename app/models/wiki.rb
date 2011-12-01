
class Wiki
  include ActiveModel::AttributeMethods

  attr_accessor :name, :raw_data, :formatted_data, :title

  #Gollum::Wiki.markup_classes = {:markdown=> ::Redcarpet::Markdown }
  DATA = Gollum::Wiki.new(Setting.wiki_repo)
  
  def page_class
  end

  def initialize(attributes = {})
    if attributes.present?
      attributes.each { |k, v| send("#{k}=", v) if respond_to?("#{k}=") }
    end
  end
  
  def self.find(name)
    data = DATA.page(name)
    if data
      new :name => data.name, :raw_data => data.raw_data, :formatted_data => data.formatted_data, :title => data.title
    end
  end
  
  def update_attributes(hash)
    raw_data = hash[:raw_data]
    data = DATA.page(name)
    DATA.update_page(data, name,:markdown, raw_data)
  end
  
  def save
    DATA.write_page(name, :markdown, raw_data)
  end
  
end
