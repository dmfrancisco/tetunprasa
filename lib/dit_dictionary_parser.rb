require 'ostruct'

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
        if !entry.glossary_english
          entry.glossary_english = clean(node.text) unless ['’', '‘'].include? node.text
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
        entry.part_of_speech = clean(node.text)
      when 'lpCategory'
        entry.categories << clean(node.text) if node.text.present?
      when 'lpMiniHeading'
        case clean(node.text)
        when "Usage"
          gloss_node = nodes[index + 1]
          if gloss_node['class'] == 'lpGlossEnglish'
            entry.usage = clean(gloss_node.text)
          else
            raise Disionariu::ParsingError,
              "`lpMiniHeading=Usage` is not associated to a `lpGlossEnglish`: #{ node }"
          end
        else
          # This is a label that gives meaning to the context that follows
          context = clean(node.text)
        end
      when 'lpEncycInfoEnglish'
        raise Disionariu::ParsingError, "Node `info` was already set." if entry.info
        entry.info = clean(node.text)
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
end
