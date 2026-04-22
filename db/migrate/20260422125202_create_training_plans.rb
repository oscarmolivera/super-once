class CreateTrainingPlans < ActiveRecord::Migration[8.1]
  def change
    create_table :training_plans, id: :uuid, default: -> { "gen_random_uuid()" } do |t|
      t.references :academy, type: :uuid, null: false, foreign_key: true
      t.references :category, type: :uuid, null: false, foreign_key: true
      t.string :title
      t.text :body

      t.timestamps
    end
  end
end
