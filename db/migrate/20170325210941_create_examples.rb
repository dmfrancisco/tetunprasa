class CreateExamples < ActiveRecord::Migration[5.0]
  def change
    create_table :examples do |t|
      t.string :tetun, null: false
      t.string :english, null: false
      t.timestamps
    end
  end
end
