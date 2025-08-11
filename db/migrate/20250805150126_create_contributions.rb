# frozen_string_literal: true

class CreateContributions < ActiveRecord::Migration[7.0]
  def change
    create_table :dataspace_contributions do |t|
      t.belongs_to :interoperable, null: false, foreign_key: { to_table: :dataspace_interoperables }
      t.string :title
      t.string :content
      t.string :locale
      t.jsonb :translations, default: {}
      t.belongs_to :parent, optional: true, index: true
      t.belongs_to :container, null: false, foreign_key: { to_table: :dataspace_containers }
    end
  end
end
