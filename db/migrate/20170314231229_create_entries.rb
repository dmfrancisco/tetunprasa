class CreateEntries < ActiveRecord::Migration[5.0]
  def change
    enable_extension "uuid-ossp"

    create_table :entries, id: :uuid do |t|
      t.string :slug, null: false
      t.string :name, null: false

      t.string :glossary_english

      t.string :male_counterpart
      t.string :female_counterpart
      t.string :info
      t.string :part_of_speech
      t.string :usage

      t.string :origin, array: true
      t.string :subentries, array: true
      t.string :antonyms, array: true
      t.string :synonyms, array: true
      t.string :similar, array: true
      t.string :counterpart, array: true
      t.string :categories, array: true
      t.string :examples_english, array: true
      t.string :examples_tetun, array: true
      t.string :cross_references, array: true
      t.string :main_cross_references, array: true
    end
  end
end
