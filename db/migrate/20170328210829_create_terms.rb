class CreateTerms < ActiveRecord::Migration[5.0]
  def change
    create_table :terms do |t|
      t.string :slug, null: false
      t.string :name, null: false

      t.timestamps
    end

    add_index :terms, :slug, unique: true
    add_index :terms, :name, unique: true
  end
end
