class AuxEntry < ApplicationRecord
  self.table_name = :entries

  extend FriendlyId
  friendly_id :name, use: :slugged

  belongs_to :term
end

class MoveEntriesColumnsToTerms < ActiveRecord::Migration[5.0]
  def up
    add_reference :entries, :term, index: true

    Entry.find_each do |entry|
      entry.term = Term.find_or_initialize_by(name: entry.name)
      entry.save!
    end

    change_column :entries, :term_id, :integer, null: false
    remove_column :entries, :name
    remove_column :entries, :slug
    remove_column :entries, :letter
  end

  def down
    add_column :entries, :name, :string
    add_column :entries, :slug, :string
    add_column :entries, :letter, :string

    AuxEntry.find_each do |entry|
      entry.name = entry.term.name
      entry.letter = I18n.transliterate(entry.name).first.upcase
      entry.save!
    end

    remove_reference :entries, :term
    change_column :entries, :name, :string, null: false
    change_column :entries, :slug, :string, null: false
    change_column :entries, :letter, :string, null: false
  end
end
