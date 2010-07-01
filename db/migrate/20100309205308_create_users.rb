class CreateUsers < ActiveRecord::Migration
  def self.up
    
    add_column "users", :login,                     :string
    add_column "users", :crypted_password,          :string, :limit => 40
    add_column "users", :salt,                      :string, :limit => 40
    add_column "users", :remember_token,            :string
    add_column "users", :remember_token_expires_at, :datetime

    User.reset_column_information
 
    users = User.find(:all)
    if !users.nil? && users.length > 0
      users.each do |u|
        u.login = u.username
        u.save
      end
    end
     
 
  end

  def self.down
    #no going back
  end
end
