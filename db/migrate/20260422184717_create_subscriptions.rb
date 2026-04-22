class CreateSubscriptions < ActiveRecord::Migration[8.1]
  def change
    create_enum :subscription_status, ['active', 'paused', 'canceled', 'past_due']
    create_enum :billing_cycle_type, ['monthly', 'annual']

    create_table :subscriptions, id: :uuid do |t|
      t.references :academy, null: false, foreign_key: true, type: :uuid
      t.references :plan, null: false, foreign_key: true, type: :uuid
      t.enum :status, enum_type: :subscription_status, default: 'active', null: false
      t.enum :billing_cycle, enum_type: :billing_cycle_type, default: 'monthly', null: false
      t.datetime :current_period_start
      t.datetime :current_period_end
      t.datetime :trial_ends_at
      t.string :stripe_subscription_id
      t.string :stripe_customer_id
      t.datetime :canceled_at
      t.text :cancellation_reason

      t.timestamps
    end
    add_index :subscriptions, :stripe_subscription_id, unique: true
    add_index :subscriptions, [:academy_id, :status]
  end
end
