class Term < ApplicationRecord
  ALPHABET = ('A'..'Z').to_a - ['C', 'Q', 'W', 'Y']
  PER_PAGE = 50

  extend FriendlyId
  friendly_id :slug_candidates, use: :slugged

  has_many :entries

  searchable do
    # For browsing
    string :letter do |t|
      I18n.transliterate(t.name).first.upcase
    end
    string :name

    # For full-text search
    text :name
    text :glossary_en do |t|
      t.entries.map(&:glossary_en).join(". ")
    end
    text :glossary_pt do |t|
      t.entries.map(&:glossary_pt).join(". ")
    end
    text :info_en do |t|
      t.entries.map(&:info_en).join(". ")
    end
    text :info_pt do |t|
      t.entries.map(&:info_pt).join(". ")
    end
    text :examples_en do |t|
      t.entries.map do |e|
        e.examples.map { |ex| [ ex.tetun, ex.english ] }
      end.flatten.join(". ")
    end
    text :examples_pt do |t|
      t.entries.map do |e|
        e.examples.map { |ex| [ ex.tetun, ex.portuguese ] }
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

  private

  def slug_candidates
    [:name, :name_and_sequence]
  end

  def name_and_sequence
    slug = name.to_param
    sequence = Term.where("slug like '#{slug}--%'").count + 2
    "#{slug}-#{sequence}"
  end
end
