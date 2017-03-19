class CreateEntries < ActiveRecord::Migration[5.0]
  def change
    enable_extension 'uuid-ossp'

    create_table :entries, id: :uuid do |t|
      t.belongs_to :parent, type: :uuid, index: true

      t.string :slug, null: false
      t.string :name, null: false
      t.string :letter, null: false

      t.text :glossary_english
      t.text :info
      t.string :male_counterpart
      t.string :female_counterpart
      t.string :part_of_speech
      t.string :usage
      t.json :examples

      t.string :origin, array: true
      t.string :antonyms, array: true
      t.string :synonyms, array: true
      t.string :similar, array: true
      t.string :categories, array: true
      t.string :counterpart, array: true
      t.string :cross_references, array: true
      t.string :variants, array: true
    end
  end
end
