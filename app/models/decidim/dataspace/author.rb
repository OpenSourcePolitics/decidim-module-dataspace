# frozen_string_literal: true

module Decidim
  module Dataspace
    class Author < Decidim::Dataspace::Interoperable
      self.table_name = "dataspace_authors"
      # rubocop:disable Rails/HasAndBelongsToMany
      has_and_belongs_to_many :contributions, join_table: :decidim_contributions_authors
      # rubocop:enable Rails/HasAndBelongsToMany
    end
  end
end
