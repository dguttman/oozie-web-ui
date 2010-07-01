class RenameApiKeyKeyField < ActiveRecord::Migration
  def self.up
    rename_column :api_keys, :key, :key_string
  end

  def self.down
    rename_column :api_keys, :key_string, :key
  end
end
