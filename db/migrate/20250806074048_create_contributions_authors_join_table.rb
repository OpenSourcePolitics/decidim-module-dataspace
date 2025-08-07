# frozen_string_literal: true

class CreateContributionsAuthorsJoinTable < ActiveRecord::Migration[7.0]
  def change
    create_join_table :contributions, :authors, table_name: :decidim_contributions_authors do |t|
      # index to retrieve faster all authors for a given contribution
      t.index [:contribution_id, :author_id], name: "index_on_contribution_id_and_author_id", unique: true
    end
  end
end
