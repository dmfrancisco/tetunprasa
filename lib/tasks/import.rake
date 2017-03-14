require "dit_dictionary_importer"

namespace :app do
  namespace :import do
    desc 'Import data from DIT (Dili Institute of Technology) Tetun-English dictionary'
    task 'dit_dictionary', [ :pattern ] => :environment do |t, args|
      if args[:pattern].blank?
        pattern = Rails.root.join('lexicon/**/*.htm')
      end

      ActiveRecord::Base.transaction do
        puts 'Extracting data from the source files...'

        Dir.glob(pattern).each do |filename|
          html_source = File.read(filename)
          entries = DitDictionaryImporter.new(html_source).parse

          entries.each do |entry|
            # TODO
          end
        end
      end
    end
  end
end
