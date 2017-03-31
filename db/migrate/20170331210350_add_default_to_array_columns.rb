class AddDefaultToArrayColumns < ActiveRecord::Migration[5.0]
  def change
    # Make array columns required with a default just to simplify the code and prevent mistakes
    change_column "entries", "origin",           :string, array: true, null: false, default: []
    change_column "entries", "antonyms",         :string, array: true, null: false, default: []
    change_column "entries", "synonyms",         :string, array: true, null: false, default: []
    change_column "entries", "similar",          :string, array: true, null: false, default: []
    change_column "entries", "categories",       :string, array: true, null: false, default: []
    change_column "entries", "counterpart",      :string, array: true, null: false, default: []
    change_column "entries", "cross_references", :string, array: true, null: false, default: []
    change_column "entries", "variants",         :string, array: true, null: false, default: []
  end
end
