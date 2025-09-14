class CreateRelationships < ActiveRecord::Migration
  def change
    create_table :relationships, :id => false do |t|
      t.integer :follower_id
      t.integer :followed_id

      t.timestamps
    end
    
    add_index :relationships, :follower_id
    add_index :relationships, :followed_id
    add_index :relationships, [:follower_id, :followed_id], unique: true

    execute "ALTER TABLE relationships ADD COLUMN id INT NOT NULL AUTO_INCREMENT PRIMARY KEY FIRST"
  end
end
