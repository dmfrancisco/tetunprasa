class CreateEntriesExamplesJoin < ActiveRecord::Migration[5.0]
  def change
    remove_column :entries, :examples, :json

    create_table :entries_examples, id: false do |t|
      t.integer :entry_id, null: false
      t.integer :example_id, null: false
    end

    add_index :entries_examples, :entry_id
    add_index :entries_examples, :example_id

    # Don't allow duplicates
    add_index :entries_examples, [:entry_id, :example_id], unique: true
  end
end
