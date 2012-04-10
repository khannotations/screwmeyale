class CreateRequests < ActiveRecord::Migration
  def change
    create_table :requests do |t|
      t.integer :from_id
      t.integer :to_id
      t.boolean :accepted, :default => nil

      t.timestamps
    end
  end
end
