class ChangeEntriesPartOfSpeechColumnToArray < ActiveRecord::Migration[5.0]
  def up
    rename_column :entries, :part_of_speech, :old_part_of_speech
    add_column :entries, :part_of_speech, :string, array: true, null: false, default: []

    Entry.reset_column_information

    Entry.find_each do |entry|
      next if entry.old_part_of_speech.blank?
      entry.part_of_speech = DitDictionaryParser.normalize_part_of_speech(entry.old_part_of_speech)
      entry.save!
    end

    remove_column :entries, :old_part_of_speech
  end

  def down
    rename_column :entries, :part_of_speech, :old_part_of_speech
    add_column :entries, :part_of_speech, :string

    Entry.reset_column_information

    Entry.find_each do |entry|
      entry.part_of_speech = entry.old_part_of_speech.join("; ")
      entry.save!
    end

    remove_column :entries, :old_part_of_speech
  end
end
