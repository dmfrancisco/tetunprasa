class Example < ApplicationRecord
  has_and_belongs_to_many :entries, uniq: true

  searchable do
    text :tetun
    text :english
  end
end
