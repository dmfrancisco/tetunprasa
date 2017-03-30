class AddTranslationsToExamples < ActiveRecord::Migration[5.0]
  def change
    add_column :examples, :portuguese, :string
  end
end
