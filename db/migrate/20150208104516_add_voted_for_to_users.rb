class AddVotedForToUsers < ActiveRecord::Migration
  def change
    add_reference :users, :voted_for, index: true
    add_foreign_key :users, :users, column: :voted_for_id, primary_key: :id
  end
end
