class AddVotedForToUsers < ActiveRecord::Migration
  def change
    add_reference :users, :voted_for, index: true
    add_foreign_key :users, :voted_fors
  end
end
