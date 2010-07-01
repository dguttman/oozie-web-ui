class CreateApiKeysTable < ActiveRecord::Migration
  def self.up
    create_table :api_keys do |t|
      t.integer :user_id
      t.string :key
    end

    
    user = User.find(:first, :conditions => ["username = ?", "rrollins"])
    unless user.nil?
      user.api_keys.create(:key => "TEST_KEY")
    end

    user = User.find(:first, :conditions => ["username = ?", "apsingh"])
    unless user.nil?
      user.api_keys.create(:key => "XFjas3ild")
    end

  

  end

  def self.down
    drop_table :api_keys
  end
end
