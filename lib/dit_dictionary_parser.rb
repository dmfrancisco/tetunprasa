require 'ostruct'
require 'nokogiri'

# Parse data from the DIT (Dili Institute of Technology) Tetun-English interactive dictionary
# You can download it here: https://goo.gl/deIvag
# More information at: http://www.tetundit.tl
#
class DitDictionaryParser
  def initialize(html_source)
    @page = Nokogiri::HTML(html_source)
  end

  def parse
    nodes = @page.css('body > *')
    entries = []

    nodes.each do |node|
      new_entry = OpenStruct.new({
        subentries: [],
        antonyms: [],
        synonyms: [],
        similar: [],
        counterpart: [],
        categories: [],
        examples: {},
        cross_references: [],
        variants: [],
        usage: [],
        origin: []
      })

      case node['class']
      when 'lpTitlePara'
        # This is the title of the page so we can ignore
      when 'lpLexEntryPara'
        entries << parse_entry(node, new_entry)
      when 'lpLexEntryPara2'
        new_entry.name = entries.last.name
        entries << parse_entry(node, new_entry)
      when 'lpLexSubEntryPara'
        entry = entries.last
        entry.subentries << parse_entry(node, new_entry)
      when 'lpLexSubEntryPara2'
        subentries = entries.last.subentries
        new_entry.name = subentries.last.name
        subentries << parse_entry(node, new_entry)
      else
        raise Disionariu::ParsingError,
          "The page includes unexpected content that is not curently parsable: #{ node }"
      end
    end

    return entries
  end

  private

  def parse_entry(parent_node, entry)
    nodes = parent_node.element_children
    context = nil

    nodes.each_with_index do |node, index|
      case node.name
      when 'a'
        if !node.css('.lpLexicalFunction').count.zero?
          node = node.at('.lpLexicalFunction')
        elsif !node.css('.lpMainCrossRef').count.zero?
          node = node.at('.lpMainCrossRef')
        elsif !node.css('.lpScientific').count.zero?
          node = node.at('.lpScientific')
        elsif !node.css('.lpCrossRef').count.zero?
          node = node.at('.lpCrossRef')
        end
      when 'sub'
        if !node.css('.lpHomonymIndex').count.zero?
          node = node.at('.lpHomonymIndex')
        end
      end

      case node['class']
      when 'lpLexEntryName'
        raise Disionariu::ParsingError, "Node `name` was already set." if entry.name
        entry.name = clean(node.text)
      when 'lpGlossEnglish'
        if !entry.glossary_en
          entry.glossary_en = clean(node.text) unless ['’', '‘'].include? node.text
        else
          # If this appears again, it's the definition of a synonym
          # This is handled below in the `lpExample` case
        end
      when 'lpPunctuation'
        # This is punctuation used in the page that is irrelevant here
      when 'lpSpAfterEntryName'
        # This is whitespace used in the page that is irrelevant here
      when 'lpPartOfSpeech'
        raise Disionariu::ParsingError, "Node `part_of_speech` was already set." if entry.part_of_speech
        entry.part_of_speech = self.class.normalize_part_of_speech(clean node.text)
      when 'lpCategory'
        entry.categories << clean(node.text) if node.text.present?
      when 'lpMiniHeading'
        case clean(node.text)
        when "Usage"
          gloss_node = nodes[index + 1]
          if gloss_node['class'] == 'lpGlossEnglish'
            entry.usage = self.class.normalize_usage(clean gloss_node.text)
          else
            raise Disionariu::ParsingError,
              "`lpMiniHeading=Usage` is not associated to a `lpGlossEnglish`: #{ node }"
          end
        else
          # This is a label that gives meaning to the context that follows
          context = clean(node.text)
        end
      when 'lpEncycInfoEnglish'
        raise Disionariu::ParsingError, "Node `info_en` was already set." if entry.info_en
        entry.info_en = clean(node.text)
      when 'lpLexicalFunction'
        if context.nil?
          puts "Node `lexical_function` defined out of context."
        else
          case context
          when "Antonym"
            entry.antonyms << clean(node.text)
          when "Synonym"
            entry.synonyms << clean(node.text)
          when "Similar"
            entry.similar << clean(node.text)
          when "CPart"
            entry.counterpart << clean(node.text)
          when "CPart.(female)"
            raise Disionariu::ParsingError, "Node `female_counterpart` was already set." if entry.female_counterpart
            entry.female_counterpart = clean(node.text)
          when "CPart.(male)"
            raise Disionariu::ParsingError, "Node `male_counterpart` was already set." if entry.male_counterpart
            entry.male_counterpart = clean(node.text)
          when "CPart CPart.(male)"
            # Same as above. This is an error in the current version of the page
            raise Disionariu::ParsingError, "Node `male_counterpart` was already set." if entry.male_counterpart
            entry.male_counterpart = clean(node.text)
          when "Specific"
            # TODO
          when "Part"
            # TODO
          when "Verb"
            # TODO
          when "Cause"
            # TODO
          when "Response"
            # TODO
          when "Instrument"
            # TODO
          when "Generic"
            # TODO
          when "Pair"
            # TODO
          when "Person"
            # TODO
          when "Category"
            # This is an error in the current version of the page
            if clean(node.text) == "halo sorumotu"
              # TODO Treat as an example
            else
              raise Disionariu::ParsingError, "Something unexpected was found: #{ node }"
            end
          when "From"
            # TODO
          when "Usage"
            # This case was handled in `lpMiniHeading`
          when "Counter"
            # TODO
          when "Phase"
            # TODO
          else
            raise Disionariu::ParsingError,
              "Unknown node context '#{ context }' in: (#{ node })"
          end
        end
      when 'lpBorrowedWord'
        origin = clean(node.text).split(' and ').map do |origin|
          case origin
          when "Port"
            "Portuguese"
          when "Indon"
            "Indonesian"
          when "English", "Japanese", "Chinese", "Korean", "Latin",
              "Malay", "Makassae", "Mambae", "Malayalam"
            origin
          else
            # The following uncommon occurrences are currently discarded:
            # - Acronym
            # - Arabic
            # - Arabic via Malay
            # - Brand name
            # - Indon calque
            # - Indon from Chinese
            # - Indon from English
            # - Port + Tetun
            # - Port Acronym
            # - Port from Japanese
            nil
          end
        end
        entry.origin = (entry.origin + origin.compact).uniq
      when 'lpSenseNumber'
        # This is used in the page for structure and is irrelevant here
      when 'lpHomonymIndex'
        # This is used in the page for homonyms and is irrelevant here
      when 'lpPhonetic'
        # TODO
      when 'lpMainCrossRef'
        entry.variants << clean(node.text)
      when 'lpScientific'
        # TODO Scientific names of plants
      when 'lpCrossRef'
        entry.cross_references << clean(node.text).sub('See ', '')
      when 'lpExample'
        gloss_node = nodes[index + 1]
        if gloss_node['class'] == 'lpGlossEnglish'
          entry.examples[clean(node.text)] = clean(gloss_node.text)
        else
          raise Disionariu::ParsingError,
            "The `lpExample` is not associated to a `lpGlossEnglish`: #{ node }"
        end
      else
        raise Disionariu::ParsingError,
          "The page includes unexpected content that is not curently parsable: #{ node }"
      end
    end

    raise Disionariu::ParsingError, "Entry with no name: #{ parent_node }" unless entry.name
    return entry
  end

  # Utility method that removes trailing whitespace and punctuation
  def clean(text)
    text
      .gsub(/[[:space:]]/, ' ')
      .strip
      .chomp(':')
  end

  # Normalizes the `part_of_speech` attribute for consistency and simpler translation
  def self.normalize_part_of_speech(part_of_speech)
    part_of_speech.chomp('.').split(/[\s;,]/).reject(&:blank?)
  end

  # Normalizes the `usage` attribute for consistency and simpler translation
  def self.normalize_usage(usages)
    usages.split(/\s*[;,]\s/).map do |usage|
      # Sometimes nil is returned because the case is covered by the `origin` field too
      case usage
      when "Baucau Viqueque Lospalos" then ["Baucau", "Viqueque", "Lospalos"]
      when "Catholic" then "Catholic church" # For consistency
      when "church formal" then ["church", "formal"]
      when "church formal TT" then ["church", "formal", "Tetun Terik"]
      when "church rare" then ["church", "rare"]
      when "church rural" then ["church", "rural"]
      when "church TT" then ["church", "Tetun Terik"]
      when "common English" then "common"
      when "common Indon" then "common"
      when "common non-technical" then ["common", "non-technical"]
      when "east" then "east of East Timor"
      when "educated formal" then ["educated", "formal"]
      when "formal church" then ["formal", "church"]
      when "formal polite" then ["formal", "polite"]
      when "Indon" then nil
      when "Indon medicine" then "medicine"
      when "Indon technical" then "technical"
      when "IsPort" then nil
      when "mainly church formal" then ["mainly church", "formal"]
      when "mainly east" then "mainly east of East Timor"
      when "mainly TT church" then ["mainly Tetun Terik", "church"]
      when "mainly TT church formal" then ["mainly Tetun Terik", "church", "formal"]
      when "media disputed" then ["media", "disputed"]
      when "new formal" then ["new", "formal"]
      when "not church" then nil # Only happens once
      when "not-all" then "not all"
      when "Port" then nil
      when "Port and medicine" then "medicine"
      when "Port medicine" then "medicine"
      when "Port pre-1975" then "pre-1975"
      when "Port technical" then "technical"
      when "post-1999 common English" then ["post-1999", "common"]
      when "post-1999 media" then ["post-1999", "media"]
      when "post-1999 medicine" then ["post-1999", "medicine"]
      when "post-1999 technical" then ["post-1999", "technical"]
      when "rare children" then ["rare", "children"]
      when "rare disputed" then ["rare", "disputed"]
      when "rare TT" then ["rare", "Tetun Terik"]
      when "Same" then nil # Only happens once
      when "south.coast" then "south coast of East Timor"
      when "to-children" then "to children"
      when "TT" then "Tetun Terik"
      else
        usage
      end
    end.flatten.compact
  end
end
