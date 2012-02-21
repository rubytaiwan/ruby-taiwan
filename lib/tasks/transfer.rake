task :transfer => ["transfer:all"]

namespace :transfer do

  desc "Transfer all data from Mongoid to ActiveRecord"
  task :all => [:system, :members, :websites, :forum, :interactions]

  desc "Transfer System (SiteConfig)"
  task :system => [:site_config]

  desc "Transfer Member (User, Authorization, Note)"
  task :members => [:user, :note]

  desc "Transfer Website List (SiteNode, Site)"
  task :websites => [:site_node, :site]

  desc "Transfer Forum (Section, Node, Topic, Reply)"
  task :forum => [:section, :node, :topic, :reply]

  desc "Transfer Interactions (Like, Following, Notification)"
  task :interactions => [:like, :following, :notification]

  DEFAULT_TIMESTAMPS = {
    :created_at => Time.now,
    :updated_at => Time.now
  }

  # System-wide

  desc "Transfer SiteConfig"
  task :site_config => [:environment] do
    transfer! Mongodb::SiteConfig, SiteConfig, :default => DEFAULT_TIMESTAMPS
  end

  # Member System

  desc "Transfer User and Authorization"
  task :user => [:environment] do

    override = {
      :state => lambda {|mongodb_user|
        if mongodb_user.respond_to? :deleted_at
          :deleted
        else
          case mongodb_user.state
          when -1
            :deleted
          when 1
            :normal
          when 2
            :blocked
          end
        end
      }, 
      :email => lambda {|mongodb_user|
        # dirty hack for user "u1325774919" who has no email
        mongodb_user.email || "guest@example.com"
      }
    }
    authorizations_table = Arel::Table.new(Authorization.table_name)
    Authorization.unscoped.delete_all!

    transfer! Mongodb::User, User, :override => override do |mongodb_user|

      # also transfers authorizations
      mongodb_user.authorizations.each do |mongodb_authorization|
        insert_row(authorizations_table, {
          :provider   => mongodb_authorization.provider,
          :uid        => mongodb_authorization.uid,
          :created_at => mongodb_authorization.created_at,
          :updated_at => mongodb_authorization.updated_at,
          :user_id    => mongodb_user._id
        })
      end
    end

  end

  desc "Transfer Note"
  task :note => [:environment] do
    transfer! Mongodb::Note, Note, :override => { :is_public => :publish }, :default => DEFAULT_TIMESTAMPS
  end

  # Websites

  desc "Transfer SiteNode"
  task :site_node => [:environment] do
    transfer! Mongodb::SiteNode, SiteNode, :default => {
      :sites_count => 0
    }.merge(DEFAULT_TIMESTAMPS)
  end

  desc "Transfer Site"
  task :site => [:environment] do
    zombie_site_ids = []

    transfer! Mongodb::Site, Site, :default => DEFAULT_TIMESTAMPS do |mongodb_site|
      zombie_site_ids << mongodb_site._id if mongodb_site.respond_to? :deleted_at
    end

    Site.destroy_all(:id => zombie_site_ids)
  end

  # Forum

  desc "Transfer Section"
  task :section => [:environment] do
    transfer! Mongodb::Section, Section, :default => DEFAULT_TIMESTAMPS
  end

  desc "Transfer Node"
  task :node => [:environment] do
    transfer! Mongodb::Node, Node, :default => {
      :topics_count => 0
    }.merge(DEFAULT_TIMESTAMPS)
  end

  desc "Transfer Topic"
  task :topic => [:environment] do
    override = {
      :visit_count => lambda { |mongodb_topic| mongodb_topic.hits.to_i }
    }

    zombie_topic_ids = []

    transfer! Mongodb::Topic, Topic, :override => override do |mongodb_topic|
      zombie_topic_ids << mongodb_topic._id if mongodb_topic.respond_to? :deleted_at
    end

    Topic.destroy_all(:id => zombie_topic_ids)
  end

  desc "Transfer Reply"
  task :reply => [:environment] do

    zombie_reply_ids = []

    transfer! Mongodb::Reply, Reply, :skip => [:mentioned_user_ids] do |mongodb_reply|
      Reply.find(mongodb_reply._id).update_attributes!(:mentioned_user_ids => mongodb_reply.mentioned_user_ids)

      zombie_reply_ids << mongodb_reply._id if mongodb_reply.respond_to? :deleted_at
    end

    Reply.destroy_all(:id => zombie_reply_ids)
  end

  # Interactions
  desc "Transfer Like"
  task :like => [:environment] do
    transfer! Mongodb::Like, Like, :override => {
      :updated_at => lambda {|mongodb_like|
        mongodb_like.created_at
      }
    }
  end

  desc "Transfer Notification"
  task :notification => [:environment] do
    transfer! Mongodb::Notification::Base, Notification::Base, :override => {
      :is_read     => :read,
      :type        => lambda {|mongodb_notification_base|
        mongodb_notification_base.class.to_s
      },
      :source_id   => lambda {|mongodb_notification_base|
        case mongodb_notification_base
        when Notification::Mention
          mongodb_notification_base.reply_id
        end
      },
      :source_type => lambda {|mongodb_notification_base|
        case mongodb_notification_base
        when Notification::Mention
          "Reply"
        end
      }, 
      :updated_at => lambda {|mongodb_notification_base|
        mongodb_notification_base.created_at
      }
    }

    # Skip Notifications other than Mention
  end

  desc "Transfer All Following"
  task :following => ["following:node"]

  namespace :following do
    desc "Transfer Node Followers"
    task :node => [:environment] do
      transfer_following!(Mongodb::Node, "Node")
      transfer_following!(Mongodb::User, "User")
      transfer_following!(Mongodb::Topic, "Topic")
    end

    def transfer_following!(mongodb_model, followable_type, follower_field=:follower_ids)

      followings_table = Arel::Table.new(Following.table_name)

      ActiveRecord::Base.connection.transaction do
        Following.unscoped.delete_all(:followable_type => followable_type)

        mongodb_model.all.each do |resource|
          $stdout.puts("#{mongodb_model}##{resource._id} has #{resource.send(follower_field).size} followers")

          resource.send(follower_field).each do |user_id|
            insert_row(followings_table, {
              :followable_type => followable_type,
              :followable_id   => resource._id,
              :user_id => user_id
            }.merge(DEFAULT_TIMESTAMPS))
          end
        end
      end
    end
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

      ar_model.unscoped.delete_all!

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

    default_values = options[:default] || {}

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
            $stdout.puts "`#{ar_column}' is fallen-back to #{value}"
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