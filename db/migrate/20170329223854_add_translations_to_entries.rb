class AddTranslationsToEntries < ActiveRecord::Migration[5.0]
  def change
    rename_column :entries, :glossary_english, :glossary_en
    rename_column :entries, :info, :info_en

    add_column :entries, :glossary_pt, :text
    add_column :entries, :info_pt, :text
  end
end
