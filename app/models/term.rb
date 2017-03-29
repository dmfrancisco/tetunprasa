class Term < ApplicationRecord
  ALPHABET = ('A'..'Z').to_a - ['C', 'Q', 'W', 'Y']
  PER_PAGE = 50

  extend FriendlyId
  friendly_id :name, use: :slugged

  has_many :entries

  searchable do
    # For browsing
    string :letter do |t|
      I18n.transliterate(t.name).first.upcase
    end
    string :name

    # For full-text search
    text :name
    text :glossary_english do |t|
      t.entries.map(&:glossary_english).join(". ")
    end
    text :info do |t|
      t.entries.map(&:info).join(". ")
    end
    text :examples do |t|
      t.entries.map do |e|
        e.examples.map { |ex| [ ex.tetun, ex.english ] }
      end.flatten.join(". ")
    end

    # Fields for filtering and sorting
    string :name_for_order do |t|
      I18n.transliterate(t.name).downcase.sub(/^\-/, '')
    end
    boolean :is_subentry do |t|
      t.entries.all? { |e| e.parent_id.present? }
    end
  end
end
