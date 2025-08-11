# frozen_string_literal: true

module Decidim
  module Dataspace
    class Author < Decidim::Dataspace::Interoperable
      self.table_name = "dataspace_authors"

      belongs_to :interoperable
      # rubocop:disable Rails/HasAndBelongsToMany
      has_and_belongs_to_many :contributions, join_table: :decidim_contributions_authors
      # rubocop:enable Rails/HasAndBelongsToMany

      delegate :reference, :source, :metadata, :created_at, :updated_at, :deleted_at, to: :interoperable
    end
  end
end
