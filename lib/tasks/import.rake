require "dit_dictionary_parser"

namespace :app do
  namespace :import do
    desc 'Import data from DIT (Dili Institute of Technology) Tetun-English dictionary'
    task 'dit_dictionary', [ :pattern ] => :environment do |t, args|
      if args[:pattern].blank?
        pattern = Rails.root.join('dit/lexicon/**/*.htm')
      end

      ActiveRecord::Base.transaction do
        puts 'Destroying all the existing entries and examples...'
        Term.destroy_all
        Entry.destroy_all
        Example.destroy_all

        puts 'Extracting entries and examples from the source files...'
        Dir.glob(pattern).each do |filename|
          html_source = File.read(filename)

          DitDictionaryParser.new(html_source).parse.each do |data|
            next if data.glossary_en.blank? && data.variants.empty? && data.subentries.empty?

            entry = Entry.new data.to_h.except(:subentries, :examples, :name).merge(pid: pid)
            entry.term = Term.find_or_create_by(name: data.name)

            data.examples.each do |tetun, english|
              entry.examples << Example.find_or_initialize_by(tetun: tetun, english: english)
            end

            subentries = data.subentries.map do |data|
              subentry = Entry.new(data.to_h.except(:subentries, :examples, :name).merge(pid: pid))
              subentry.term = Term.find_or_create_by(name: data.name)

              data.examples.each do |tetun, english|
                subentry.examples << Example.find_or_create_by(tetun: tetun, english: english)
              end
              subentry
            end

            entry.subentries = subentries.reject { |s| s.glossary_en.blank? && s.variants.empty? }
            entry.save!
          end
        end
      end

      # Update search indexes
      Term.reindex
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
