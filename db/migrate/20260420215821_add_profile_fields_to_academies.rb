class AddProfileFieldsToAcademies < ActiveRecord::Migration[8.0]
  def change
    add_column :academies, :description,   :text
    add_column :academies, :city,          :string
    add_column :academies, :country,       :string,  default: "ES"
    add_column :academies, :phone,         :string
    add_column :academies, :website,       :string
    add_column :academies, :primary_color, :string,  default: "#4f46e5"   # indigo-600
  end
end
