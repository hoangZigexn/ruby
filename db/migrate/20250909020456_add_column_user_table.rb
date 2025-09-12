class AddColumnUserTable < ActiveRecord::Migration
  def change
    add_column :users, :username  , :string
    add_column :users, :gender, :integer
    add_column :users, :last_name, :string
    add_column :users, :first_name, :string
    add_column :users, :birthday, :date
  end
end
