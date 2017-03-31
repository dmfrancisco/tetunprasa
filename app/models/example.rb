class Example < ApplicationRecord
  has_and_belongs_to_many :entries, uniq: true

  searchable do
    text :tetun
    text :english
    text :portuguese
  end

  validates :tetun, :english, :portuguese, presence: true

  # Gives the translation based on the given locale
  def translation(locale)
    locale == 'pt' ? portuguese : english
  end
end
