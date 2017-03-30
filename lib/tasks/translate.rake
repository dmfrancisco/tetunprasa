require 'google/cloud/translate'

namespace :app do
  namespace :translate do
    desc 'Translate glossary attribute for entries using Google Translate'
    task 'entries_glossary' => :environment do
      Entry.find_each do |entry|
        next if entry.glossary_pt.present? || entry.glossary_en.blank?

        entry.glossary_pt = client.translate(entry.glossary_en, from: "en", to: "pt")
        entry.save!
      end
    end

    desc 'Translate info attribute for entries using Google Translate'
    task 'entries_info' => :environment do
      Entry.find_each do |entry|
        next if entry.info_pt.present? || entry.info_en.blank?

        entry.info_pt = client.translate(entry.info_en, from: "en", to: "pt")
        entry.save!
      end
    end

    desc 'Translate examples using Google Translate'
    task 'examples' => :environment do
      Example.find_each do |example|
        next if example.portuguese.present?

        example.portuguese = client.translate(example.english, from: "en", to: "pt")
        example.save!
      end
    end
  end

  def client
    @_client ||= Google::Cloud::Translate.new(project: ENV["GOOGLE_PROJECT_NAME"])
  end
end
