class AddMetadataToEntries < ActiveRecord::Migration[5.0]
  def change
    add_column :entries, :metadata, :jsonb, default: {}, null: false

    # Re-run the callbacks for the existing data
    Entry.find_each(&:save) unless reverting?
  end
end
