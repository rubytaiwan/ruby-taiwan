class Wiki
  
  include ActiveModel::Validations  
  include ActiveModel::Conversion  
  extend ActiveModel::Naming  
  
  attr_accessor :name, :raw_data, :formatted_data, :title, :path
 # include ActiveModel::AttributeMethods
 # extend ActiveModel::Naming
 # include ActiveModel::Conversion
 # 
 
 def initialize(attributes = {})  
   attributes.each do |name, value|  
     send("#{name}=", value)  
   end  
 end
 

  def persisted?
    false
  end
  
  DATA = Gollum::Wiki.new(Setting.wiki_repo, :base_path => "/giki")
  
  def self.find(name)
    data = DATA.page(name)
    if data
      new :name => data.name, :raw_data => data.raw_data, :formatted_data => data.formatted_data, :title => data.title, :path => data.path
    end
  end
  
  def update_attributes(hash)
    raw_data = hash[:raw_data]
    name = hash[:name]
    data = DATA.page(name)
    DATA.update_page(data, name,:markdown, raw_data)
  end
  
  def save
    DATA.write_page(name, :markdown, raw_data)
  end
  
end
