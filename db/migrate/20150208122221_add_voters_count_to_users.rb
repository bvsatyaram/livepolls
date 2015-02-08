class AddVotersCountToUsers < ActiveRecord::Migration
  def change
    add_column :users, :voters_count, :integer, default: 0
  end
end
