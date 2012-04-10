class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :fname
      t.string :lname
      t.string :nickname
      t.string :email
      t.string :college
      t.string :year
      t.string :picture

      t.string :netid
      t.integer :gender, :default => 0
      t.integer :preference, :default => 0
      t.string :major, :default => ""

      t.boolean :active, :default => false
      
      t.timestamps
    end
  end
end
