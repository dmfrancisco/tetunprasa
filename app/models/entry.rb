class Entry < ApplicationRecord
  RELATED_TYPES = [ :similar, :synonyms, :antonyms, :male_counterpart,
    :female_counterpart, :counterpart, :variants, :cross_references ]

  belongs_to :term, required: true
  belongs_to :parent, class_name: 'Entry', foreign_key: 'parent_id'
  has_many :subentries, class_name: 'Entry', foreign_key: 'parent_id'
  has_and_belongs_to_many :examples, uniq: true

  after_save :reindex_term

  # @return [String] A short ID that can be used in the public UI
  def related_to_ref(type)
    type_index = RELATED_TYPES.index(type)
    $hashids.encode(pid, type_index)
  end

  # @return [Array] List of related entries given a short ID
  def self.related_from_ref(short_id)
    pid, type_index = $hashids.decode(short_id)
    related_type = RELATED_TYPES[type_index]
    Entry.find_by(pid: pid).send(related_type)
  rescue
    # In case the user provided an invalid `short_id`
  end

  # Appends `_en` or `_pt` to the field according to a given locale
  def translated(field, locale)
    if locale == 'pt'
      send("#{ field }_pt")
    else
      send("#{ field }_en")
    end
  end

  private

  def reindex_term
    Sunspot.index(term)
  end
end
