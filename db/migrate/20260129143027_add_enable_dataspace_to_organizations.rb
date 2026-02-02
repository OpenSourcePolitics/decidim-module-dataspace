# frozen_string_literal: true

class AddEnableDataspaceToOrganizations < ActiveRecord::Migration[7.0]
  def up
    add_column :decidim_organizations, :enable_dataspace, :boolean, default: false, null: false
  end

  def down
    remove_column :decidim_organizations, :enable_dataspace
  end
end
