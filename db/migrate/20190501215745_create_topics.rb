class CreateTopics < ActiveRecord::Migration[5.2]
  def change
    create_table :topics do |t|
      t.text :text
      t.boolean :reported, :default => false
      t.string :delete_password
      t.string :board

      t.timestamps
    end
  end
end
