class AlgoliaChanges < ActiveRecord::Migration
  def change
    create_table :members do |t|
      t.integer :comment_karma
      t.integer :story_karma
      t.integer :poll_karma
    end
  end
end
