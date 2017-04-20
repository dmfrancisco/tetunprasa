class Entry < ApplicationRecord
  RELATED_TYPES = [ :similar, :synonyms, :antonyms, :male_counterpart,
    :female_counterpart, :counterpart, :variants, :cross_references ]

  belongs_to :term, required: true
  belongs_to :parent, class_name: 'Entry', foreign_key: 'parent_id'
  has_many :subentries, class_name: 'Entry', foreign_key: 'parent_id'
  has_and_belongs_to_many :examples, uniq: true

  after_save :reindex_term

  # This temporary callback and scope will help us enhance portuguese translations
  # by detecting duplicate words resulting from english synonyms. For eg
  # "tall, high" is translated to "alto, alto" and we want to manually fix that.
  before_save :check_duplicate_pt_words
  store_accessor :metadata, :has_duplicate_pt_words, :updated_by
  scope :with_duplicate_pt_words, -> { where("metadata->>'has_duplicate_pt_words' = ?", 'true') }
  scope :manually_updated, -> { where("(metadata->>'updated_by') is not null") }

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

  def glossary
    I18n.locale == :pt ? glossary_pt : glossary_en
  end

  def info
    I18n.locale == :pt ? info_pt : info_en
  end

  def origin_en
    read_attribute :origin
  end

  def origin
    I18n.locale == :pt ? origin_en.map { |o| I18n.t("origin.#{ o }") } : origin_en
  end

  def part_of_speech_en
    read_attribute :part_of_speech
  end

  def part_of_speech
    if I18n.locale == :pt
      part_of_speech_en.map { |ps| I18n.t("part_of_speech.#{ ps }", default: ps) }
    else
      part_of_speech_en
    end
  end

  def usage_en
    read_attribute :usage
  end

  def usage
    I18n.locale == :pt ? usage_en.map { |u| I18n.t("usage.#{ u }") } : usage_en
  end

  private

  def reindex_term
    Sunspot.index(term)
  end

  def check_duplicate_pt_words
    self.has_duplicate_pt_words = glossary_pt.split(/[^\w']+/)
      .reject { |w| w.length <= 2 } # Ignore words with less than 2 characters
      .group_by(&:to_s).map { |w| w[1].length } # Count occurrences
      .max.to_i > 2 if glossary_pt.present? # Check if at least one word is repeated
  end
end
