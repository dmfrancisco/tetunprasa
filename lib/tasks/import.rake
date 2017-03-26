require "dit_dictionary_parser"

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
          entries = DitDictionaryParser.new(html_source).parse

          entries.each do |entry|
            next if entry.glossary_english.blank? && entry.variants.empty? && entry.subentries.empty?

            record = Entry.new entry.to_h.except(:subentries)
            subentries = entry.subentries.map do |subentry|
              Entry.new subentry.to_h.except(:subentries)
            end

            record.subentries << subentries.reject { |e| e.glossary_english.blank? && e.variants.empty? }
            record.save!
          end
        end
      end

      # Update search index
      Entry.reindex
    end
  end
end
