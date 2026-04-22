class AddAcademyToCategories < ActiveRecord::Migration[8.1]
  def change
    add_reference :categories, :academy, type: :uuid, null: false, foreign_key: true
  end
end
