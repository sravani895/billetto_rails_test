class CreateEvents < ActiveRecord::Migration[8.1]
  def change
    create_table :events do |t|
      t.string :billetto_id
      t.string :title
      t.text :description
      t.datetime :start_at
      t.string :image_url

      t.timestamps
    end
  end
end
