class AlgoliaChanges < ActiveRecord::Migration
  def up
  	add_column :member, :comment_karma, :integer
  	add_column :member, :story_karma, :integer

  end
  def down

  end
end
