# frozen_string_literal: true

class AddReferenceColumnToComments < ActiveRecord::Migration[7.0]
  def up
    add_column :decidim_comments_comments, :reference, :string
  end

  def down
    remove_column :decidim_comments_comments, :reference
  end
end
