# frozen_string_literal: true

module Decidim
  module Dataspace
    class Contribution < Decidim::Dataspace::Interoperable
      self.table_name = "dataspace_contributions"

      belongs_to :interoperable, inverse_of: :container, class_name: "Decidim::Dataspace::Interoperable", dependent: :destroy
      belongs_to :container, class_name: "Decidim::Dataspace::Container"
      belongs_to :parent, class_name: "Decidim::Dataspace::Contribution", inverse_of: :children, optional: true
      has_many :children, foreign_key: "parent_id", class_name: "Decidim::Dataspace::Contribution", inverse_of: :parent, dependent: :destroy
      # rubocop:disable Rails/HasAndBelongsToMany
      has_and_belongs_to_many :authors, join_table: :decidim_contributions_authors
      # rubocop:enable Rails/HasAndBelongsToMany

      validate :title_or_content

      delegate :reference, :source, :metadata, :created_at, :updated_at, :deleted_at, to: :interoperable

      private

      def title_or_content
        errors.add :base, "Title or content must be present" if title.blank? && content.blank?
      end
    end
  end
end
