class AddUniqueIndexToEventsBillettoId < ActiveRecord::Migration[8.1]
  def change
    add_index :events, :billetto_id, unique: true
  end
end
