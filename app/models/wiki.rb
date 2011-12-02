class Wiki

  include ActiveModel::AttributeMethods
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming
  
  attr_accessor :name, :raw_data, :formatted_data, :title, :path, :change_desc, :versions
  # name, raw_data, :formatted_data, :title  for input
  # :path for .md path
  # change_desc for commit log

  DATA = Gollum::Wiki.new(Setting.wiki_repo, :base_path => "/wiki")

  def initialize(attributes = {})
    attributes.each do |name, value|
      send("#{name}=", value)
    end
  end

  def persisted?
    false
  end

  def self.find(name)
    data = DATA.page(name)
    if data
      new :name => data.name,
          :raw_data => data.raw_data,
          :formatted_data => data.formatted_data, 
          :title => data.title, 
          :path => data.path, 
          :versions => data.versions
    end
  end

  def update_attributes(hash,commit)
    raw_data = hash[:raw_data]
    name = hash[:name]
    data = DATA.page(name)
    DATA.update_page(data, name,:markdown, raw_data, commit )
  end

  def save(commit)
    DATA.write_page(name, :markdown, raw_data, commit)
  end

end
