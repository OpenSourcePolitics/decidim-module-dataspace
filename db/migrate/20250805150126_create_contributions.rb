# frozen_string_literal: true

class CreateContributions < ActiveRecord::Migration[7.0]
  def change
    create_table :dataspace_contributions do |t|
      t.string :reference, null: false
      t.string :source, null: false
      t.timestamp :deleted_at
      t.jsonb :metadata, default: {}
      t.string :title
      t.string :content
      t.string :locale
      t.jsonb :translations
      t.belongs_to :parent, optional: true, index: true
      t.belongs_to :container, null: false, foreign_key: { to_table: :dataspace_containers }

      t.timestamps
    end
  end
end
