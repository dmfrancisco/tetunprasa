class Entry < ApplicationRecord
  extend FriendlyId

  belongs_to :parent, class_name: 'Entry', foreign_key: 'parent_id'
  has_many :subentries, class_name: 'Entry', foreign_key: 'parent_id'

  friendly_id :slug_candidates, use: :slugged

  searchable do
    string :letter

    text :name
    text :glossary_english
    text :info
    text :examples

    # Fields for grouping and sorting
    string(:name_for_group) { |e| e.name.downcase }
    string(:name_for_order) { |e| I18n.transliterate(e.name).downcase }
    boolean(:is_subentry) { |e| e.parent_id.present? }
  end

  def slug_candidates
    [:name, :name_and_sequence]
  end

  def name_and_sequence
    slug = name.to_param
    sequence = Entry.where("slug like '#{slug}--%'").count + 2
    "#{slug}-#{sequence}"
  end
end
