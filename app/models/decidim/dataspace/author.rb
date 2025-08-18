# frozen_string_literal: true

module Decidim
  module Dataspace
    class Author < Decidim::Dataspace::Interoperable
      self.table_name = "dataspace_authors"

      belongs_to :interoperable, inverse_of: :container, class_name: "Decidim::Dataspace::Interoperable", dependent: :destroy
      # rubocop:disable Rails/HasAndBelongsToMany
      has_and_belongs_to_many :contributions, join_table: :decidim_contributions_authors
      # rubocop:enable Rails/HasAndBelongsToMany

      accepts_nested_attributes_for :interoperable

      delegate :reference, :source, :created_at, :updated_at, :deleted_at, to: :interoperable
    end
  end
end
