class Entry < ApplicationRecord
  extend FriendlyId

  ALPHABET = ('A'..'Z').to_a - ['C', 'Q', 'W', 'Y']
  RELATED_TYPES = [ :similar, :synonyms, :antonyms, :male_counterpart,
    :female_counterpart, :counterpart, :variants, :cross_references ]
  PER_PAGE = 50

  belongs_to :parent, class_name: 'Entry', foreign_key: 'parent_id'
  has_many :subentries, class_name: 'Entry', foreign_key: 'parent_id'

  friendly_id :slug_candidates, use: :slugged

  searchable do
    string :letter
    string :name

    text :name, stored: true
    text :glossary_english, stored: true
    text :info
    text :examples

    # Fields for grouping and sorting
    string(:name_for_order) { |e| I18n.transliterate(e.name).downcase.sub(/^\-/, '') }
    boolean(:is_subentry) { |e| e.parent_id.present? }
  end

  # @return [String] A short ID that can be used in the public UI
  def related_to_ref(type)
    type_index = RELATED_TYPES.index(type)
    $hashids.encode(id, type_index)
  end

  # @return [Array] List of related entries given a short ID
  def self.related_from_ref(short_id)
    id, type_index = $hashids.decode(short_id)
    related_type = RELATED_TYPES[type_index]
    Entry.find(id).send(related_type)
  end

  private

  def slug_candidates
    [:name, :name_and_sequence]
  end

  def name_and_sequence
    slug = name.to_param
    sequence = Entry.where("slug like '#{slug}--%'").count + 2
    "#{slug}-#{sequence}"
  end
end
