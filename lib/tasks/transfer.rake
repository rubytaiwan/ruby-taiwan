namespace :transfer do
  desc "Transfer all data from Mongoid to ActiveRecord"
  task :all => [:site_config, :site_node, :node]

  desc "SiteConfig"
  task :site_config => [:environment] do
    transfer! Mongodb::SiteConfig, SiteConfig
  end

  desc "SiteNode"
  task :site_node => [:environment] do
    transfer! Mongodb::SiteNode, SiteNode, :default => {
      :sites_count => 0
    }
  end

  desc "Node"
  task :node => [:environment] do
    transfer! Mongodb::Node, Node, :default => {
      :topics_count => 0
    }
  end


  def transfer!(mongodb_model, ar_model, options={}, &callback)

    skip_columns         = options[:skip]      # ActiveRecord columns
    override_assignments = options[:override]  # ActiveRecord => MongoDB
    default_values       = options[:default]   # default value of a column when exception raised

    table       = Arel::Table.new(ar_model.table_name)

    ar_columns  = table.columns.map {|column| column.name }

    # skip some columns
    ar_columns -= skip_columns if skip_columns

    ActiveRecord::Base.connection.transaction do

      ar_model.delete_all!

      mongodb_model.all.each do |resource|
        $stdout.puts("#{ar_model.name} ##{resource.id}")

        # build assignments for INSERT sql query
        assignments = build_assignments(resource, ar_columns,
                                        :override => override_assignments, 
                                        :default => default_values)

        # directly issue INSERT query to MySQL
        insert_row(table, assignments)

        # some further process to do
        callback.call(resource) if callback
      end
    end
  end

  def insert_row(table, assignments)

    stmt = build_statement(table, assignments)

    ActiveRecord::Base.connection.insert(stmt)
  end

  # should fetch actual values, i.e.
  # {
  #   :id => 3, :name => "John", :email => "john@appleseed.com"
  # }
  def build_assignments(resource, ar_columns, options={})
    override = { :id => :_id }
    override.merge!(options[:override]) if options[:override]

    default_values = options[:default_values] || {}

    assignments = {}

    ar_columns.each do |ar_column|
      overrider = override[ar_column]
      if overrider
        case overrider
        when Proc # lambda or Proc
          value = overrider.call(resource)
        when Symbol, String # column name
          value = resource.send(overrider.to_sym)
        else
          raise "cannot override field #{ar_column}: you should pass a lambda or field name of MongoDB"
        end
      else
        begin
          value = resource.send(ar_column)
        rescue => e
          # fallback to default value if possible
          if default_values[ar_column]
            value = default_values[ar_column]
          else
            $stderr.puts "`#{ar_column}' field doesn't exist in #{resource}; it will fallback to default value of database (might be NULL)"
          end
        end
      end

      assignments[ar_column] = value
    end

    assignments
  end

  def build_statement(table, assignments)
    assignments_with_field = {}
    assignments.map do |key,value|
      assignments_with_field[table[key.to_s]] = value
    end

    table.compile_insert(assignments_with_field)
  end
end