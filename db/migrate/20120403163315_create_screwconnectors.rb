class CreateScrewconnectors < ActiveRecord::Migration
  def change
    create_table :screwconnectors do |t|
      t.integer :intensity
      t.string :event
      t.integer :screw_id
      t.integer :screwer_id
      t.integer :match_id, :default => 0 # The client it's matched with, if any

      t.timestamps
    end
  end
end
