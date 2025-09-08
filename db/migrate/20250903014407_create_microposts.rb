class CreateMicroposts < ActiveRecord::Migration
  def change
    create_table :microposts, :id => false do |t|
      t.text :content
      t.references :user

      t.timestamps
    end
    
    execute "ALTER TABLE microposts ADD COLUMN id INT NOT NULL AUTO_INCREMENT PRIMARY KEY FIRST"
    add_index :microposts, :user_id
  end
end
