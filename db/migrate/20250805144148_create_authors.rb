# frozen_string_literal: true

class CreateAuthors < ActiveRecord::Migration[7.0]
  def change
    create_table :dataspace_authors do |t|
      t.string :reference, null: false
      t.string :source, null: false
      t.timestamp :deleted_at
      t.jsonb :metadata, default: {}
      t.string :name

      t.timestamps
    end
  end
end
