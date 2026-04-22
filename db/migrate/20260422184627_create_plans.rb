class CreatePlans < ActiveRecord::Migration[8.1]
  def change
    create_enum :plan_tier, ['free', 'starter', 'pro']
    create_table :plans, id: :uuid do |t|
      t.enum :tier, enum_type: :plan_tier, default: 'free', null: false
      t.string :name, null: false, index: { unique: true }
      t.text :description
      t.integer :price_cents, default: 0, null: false
      t.integer :monthly_cost_cents, default: 0, null: false
      t.integer :trial_days, default: 14, null: false
      t.text :features
      t.boolean :visible, default: true, null: false
      t.string :stripe_product_id
      t.string :stripe_price_id

      t.timestamps
    end
    add_index :plans, :tier, unique: true
    add_index :plans, :stripe_product_id, unique: true
  end
end
