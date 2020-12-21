class RenameHashedPasswordColumnToUsers < ActiveRecord::Migration[6.0]
  def change
    rename_column :users, :hashed_password, :password_digest
  end
end
