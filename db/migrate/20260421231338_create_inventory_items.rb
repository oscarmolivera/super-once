class CreateInventoryItems < ActiveRecord::Migration[8.1]
  def change
    create_table :inventory_items, id: :uuid do |t|
      t.references :academy, null: false, foreign_key: true, type: :uuid

      t.string   :name,        null: false
      t.string   :description
      t.integer  :quantity,    null: false, default: 0
      t.integer  :condition,   null: false, default: 0  # enum: new/good/fair/poor
      t.integer  :category,    null: false, default: 0  # enum: equipment/apparel/medical/office/other
      t.decimal  :unit_value,  precision: 10, scale: 2
      t.date     :acquired_on
      t.string   :location                              # storage room, locker, etc.

      t.timestamps
    end

    add_index :inventory_items, [:academy_id, :category]
    add_index :inventory_items, [:academy_id, :condition]
  end
end
