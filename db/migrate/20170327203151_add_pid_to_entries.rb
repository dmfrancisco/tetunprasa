class AddPidToEntries < ActiveRecord::Migration[5.0]
  def up
    add_column :entries, :pid, :integer

    # Migrate existing data
    Entry.all.each { |e| e.update_column(:pid, e.id) }

    # Make the new column required and unique
    change_column :entries, :pid, :integer, null: false
    add_index :entries, :pid, unique: true
  end

  def down
    remove_column :entries, :pid
  end
end
