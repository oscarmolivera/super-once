class CreateTaxPermits < ActiveRecord::Migration[8.1]
  def change
    create_table :tax_permits, id: :uuid do |t|
      t.references :academy, null: false, foreign_key: true, type: :uuid

      t.string  :name,          null: false   # "VAT registration", "Operating permit"
      t.integer :document_type, null: false, default: 0  # enum: tax/permit/insurance/license/other
      t.string  :reference_number
      t.date    :issued_on
      t.date    :expires_on
      t.integer :status,        null: false, default: 0  # enum: active/expired/pending_renewal
      t.string  :issuing_authority
      t.string  :notes

      t.timestamps
    end

    add_index :tax_permits, [:academy_id, :document_type]
    add_index :tax_permits, [:academy_id, :expires_on]
    add_index :tax_permits, [:academy_id, :status]
  end
end
