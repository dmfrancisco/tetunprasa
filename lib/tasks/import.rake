require "dit_dictionary_parser"

namespace :app do
  namespace :import do
    desc 'Import data from DIT (Dili Institute of Technology) Tetun-English dictionary'
    task 'dit_dictionary', [ :pattern ] => :environment do |t, args|
      if args[:pattern].blank?
        pattern = Rails.root.join('lexicon/**/*.htm')
      end

      ActiveRecord::Base.transaction do
        puts 'Destroying all the existing entries and examples...'
        Entry.destroy_all
        Example.destroy_all

        puts 'Extracting entries and examples from the source files...'
        Dir.glob(pattern).each do |filename|
          html_source = File.read(filename)

          DitDictionaryParser.new(html_source).parse.each do |data|
            next if data.glossary_english.blank? && data.variants.empty? && data.subentries.empty?

            entry = Entry.new data.to_h.except(:subentries, :examples).merge(pid: pid)
            data.examples.each do |tetun, english|
              entry.examples << Example.find_or_initialize_by(tetun: tetun, english: english)
            end

            subentries = data.subentries.map do |data|
              Entry.new(data.to_h.except(:subentries, :examples).merge(pid: pid)).tap do |subentry|
                data.examples.each do |tetun, english|
                  subentry.examples << Example.find_or_initialize_by(tetun: tetun, english: english)
                end
              end
            end

            entry.subentries = subentries.reject { |s| s.glossary_english.blank? && s.variants.empty? }
            entry.save!
          end
        end
      end

      # Update search indexes
      Entry.reindex
      Example.reindex
    end

    # Sequential ID that we use internally for the related entries feature
    # This method increments a global counter
    def pid
      $pid ||= 0
      $pid += 1
    end
  end
end
