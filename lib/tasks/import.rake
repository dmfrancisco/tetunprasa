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

          entries.each do |entry|
            record = Entry.new entry.to_h.except(:subentries)
            subentries = entry.subentries.map do |subentry|
              Entry.new subentry.to_h.except(:subentries)
            end

            # Ignore known "---" fake subentries
            record.subentries << subentries.reject { |e| e.name == '-' * 73 }
            record.save!
          end
        end

        # Update search index
        Entry.reindex
      end
    end
  end
end
