namespace :transfer do
  desc "Transfer all data from Mongoid to ActiveRecord"
  task :all => [:site_config]

  desc "SiteConfig"
  task :site_config => [:environment] do
    transfer! Mongodb::SiteConfig, SiteConfig do |site_config|
      {
        :id     => site_config._id,
        :key    => site_config.key,
        :value  => site_config.value
      }
    end
  end

  def transfer!(mongodb_model, ar_model, &block)
    ar_model.delete_all!

    ActiveRecord::Base.connection.transaction do

      table = Arel::Table.new(ar_model.table_name)

      mongodb_model.all.each do |resource|
        assignments = block.call(resource)
        assignments[:created_at] = resource.try(:created_at) rescue nil
        assignments[:updated_at] = resource.try(:updated_at) rescue nil
        insert_resource(table, resource, assignments)

        $stdout.puts("#{ar_model.name} ##{resource.id}")
      end
    end
  end

  def insert_resource(table, resource, assignments)

    stmt = build_statement(table, assignments)

    ActiveRecord::Base.connection.insert(stmt)
  end

  def build_statement(table, assignments)
    assignments_with_field = {}
    assignments.map do |key,value|
      assignments_with_field[table[key.to_s]] = value
    end

    table.compile_insert(assignments_with_field)
  end
end