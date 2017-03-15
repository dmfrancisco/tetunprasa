class Entry < ApplicationRecord
  extend FriendlyId

  friendly_id :slug_candidates, use: :slugged

  def slug_candidates
    [:name, :name_and_sequence]
  end

  def name_and_sequence
    slug = name.to_param
    sequence = Entry.where("slug like '#{slug}--%'").count + 2
    "#{slug}-#{sequence}"
  end
end
