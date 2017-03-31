class ChangeEntriesUsageColumnToArray < ActiveRecord::Migration[5.0]
  def up
    rename_column :entries, :usage, :old_usage
    add_column :entries, :usage, :string, array: true, null: false, default: []

    Entry.reset_column_information

    Entry.find_each do |entry|
      next if entry.old_usage.blank?

      entry.usage = DitDictionaryParser.normalize_usage(entry.old_usage)
      entry.save!
    end

    remove_column :entries, :old_usage
  end

  def down
    rename_column :entries, :usage, :old_usage
    add_column :entries, :usage, :string

    Entry.reset_column_information

    Entry.find_each do |entry|
      entry.usage = entry.old_usage.join("; ")
      entry.save!
    end

    remove_column :entries, :old_usage
  end
end
