# frozen_string_literal: true

class CreateAuthors < ActiveRecord::Migration[7.0]
  def change
    create_table :dataspace_authors do |t|
      t.belongs_to :interoperable, null: false, foreign_key: { to_table: :dataspace_interoperables }
      t.string :name
    end
  end
end
