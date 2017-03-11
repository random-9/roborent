class AddFieldsToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :first_name, :string
    add_column :users, :last_name, :string
    add_column :users, :phone, :string
    add_column :users, :nationality, :string
    add_column :users, :occupation, :string
    add_column :users, :photo, :string
  end
end
