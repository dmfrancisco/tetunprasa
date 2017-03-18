class Entry < ApplicationRecord
  extend FriendlyId

  belongs_to :parent, class_name: 'Entry', foreign_key: 'parent_id'
  has_many :subentries, class_name: 'Entry', foreign_key: 'parent_id'

  friendly_id :slug_candidates, use: :slugged

  searchable do
    text :name
    text :glossary_english
    text :info
    text :examples
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
