class AddForeignKeyCategoriesToSportSchools < ActiveRecord::Migration[8.1]
  def change
    add_foreign_key :categories, :sport_schools
    add_index :categories, [:academy_id, :sport_school_id, :name]
  end
end
