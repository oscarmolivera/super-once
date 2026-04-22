class CreateAnnouncements < ActiveRecord::Migration[8.1]
  def change
    create_table :announcements, id: :uuid, default: -> { "gen_random_uuid()" } do |t|
      t.references :academy, type: :uuid, null: false, foreign_key: true
      t.references :category, type: :uuid, null: true, foreign_key: true
      t.string :title
      t.text :body
      t.datetime :published_at

      t.timestamps
    end

    add_index :announcements, [:academy_id, :category_id, :published_at]
  end
end
