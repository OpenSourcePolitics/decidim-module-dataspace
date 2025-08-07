# frozen_string_literal: true

class CreateContainers < ActiveRecord::Migration[7.0]
  def change
    create_table :dataspace_containers do |t|
      t.string :reference, null: false
      t.string :source, null: false
      t.timestamp :deleted_at
      t.jsonb :metadata, default: {}
      t.string :name
      t.string :description

      t.timestamps
    end
  end
end
