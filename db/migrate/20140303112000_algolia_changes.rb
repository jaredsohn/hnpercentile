class AlgoliaChanges < ActiveRecord::Migration
  def up
  	add_column :comment_karma, :story_karma, :poll_karma, :integer
  end
  def down

  end
end
