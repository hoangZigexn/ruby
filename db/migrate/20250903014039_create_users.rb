class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users, :id => false do |t|
      t.string :name
      t.string :email

      t.timestamps
    end
    
    execute "ALTER TABLE users ADD COLUMN id INT NOT NULL AUTO_INCREMENT PRIMARY KEY FIRST"
  end
end
