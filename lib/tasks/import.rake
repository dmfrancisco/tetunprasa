require "dit_dictionary_importer"

namespace :app do
  namespace :import do
    desc 'Import data from DIT (Dili Institute of Technology) Tetun-English dictionary'
    task 'dit_dictionary', [ :pattern ] => :environment do |t, args|
      if args[:pattern].blank?
        pattern = Rails.root.join('lexicon/**/*.htm')
      end

      ActiveRecord::Base.transaction do
        puts 'Destroying all the existing entries...'
        Entry.destroy_all

        puts 'Extracting entries from the source files...'

        Dir.glob(pattern).each do |filename|
          html_source = File.read(filename)
          entries = DitDictionaryImporter.new(html_source).parse

          entries.map { |entry| [ entry, entry.subentries ] }.flatten.each do |entry|
            Entry.create!({
              subentries: entry.subentries.map(&:name),
              name: entry.name,
              glossary_english: entry.glossary_english,
              male_counterpart: entry.male_counterpart,
              female_counterpart: entry.female_counterpart,
              info: entry.info,
              part_of_speech: entry.part_of_speech,
              usage: entry.usage,
              origin: entry.origin,
              antonyms: entry.antonyms,
              synonyms: entry.synonyms,
              similar: entry.similar,
              counterpart: entry.counterpart,
              categories: entry.categories,
              examples_english: entry.examples_english,
              examples_tetun: entry.examples_tetun,
              cross_references: entry.cross_references,
              main_cross_references: entry.main_cross_references
            })
          end
        end
      end
    end
  end
end
