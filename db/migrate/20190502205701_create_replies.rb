class CreateReplies < ActiveRecord::Migration[5.2]
  def change
    create_table :replies do |t|
      t.text :text
      t.boolean :reported, :default => false
      t.string :delete_password
      t.integer :topic_id
      t.timestamps
    end
  end
end
