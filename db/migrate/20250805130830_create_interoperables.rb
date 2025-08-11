# frozen_string_literal: true

class CreateInteroperables < ActiveRecord::Migration[7.0]
  def change
    create_table :dataspace_interoperables do |t|
      t.string :reference, null: false, index: { unique: true }
      t.string :source, null: false
      t.timestamp :deleted_at
      t.jsonb :metadata, default: {}

      t.timestamps
    end
  end
end
