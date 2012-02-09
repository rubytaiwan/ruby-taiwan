class Following < ActiveRecord::Base
  belongs_to :followable, :polymorphic => true
  belongs_to :user

  validates_uniqueness_of :followable_id, :scope => [:user_id, :followable_type]
end
