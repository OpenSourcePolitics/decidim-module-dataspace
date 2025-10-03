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

      def self.from_proposals
        Decidim::Proposals::Proposal.published
                                    .not_hidden
                                    .only_amendables
                                    .includes(:component).all.map do |proposal|
          {
            reference: proposal.reference,
            source: Decidim::ResourceLocatorPresenter.new(proposal).url,
            container: proposal.component.participatory_space_type.constantize.find(proposal.component.participatory_space_id).reference,
            locale: "en",
            title: proposal.title["en"],
            content: proposal.body["en"],
            authors: Contribution.authors(proposal),
            created_at: proposal.created_at,
            updated_at: proposal.updated_at,
            deleted_at: nil # does not exist in proposal
          }
        end
      end

      def self.proposal(params_reference)
        proposal = Decidim::Proposals::Proposal.find_by(reference: params_reference)
        return nil unless proposal

        {
          reference: proposal.reference,
          source: Decidim::ResourceLocatorPresenter.new(proposal).url,
          container: proposal.component.participatory_space_type.constantize.find(proposal.component.participatory_space_id).reference,
          locale: "en",
          title: proposal.title["en"],
          content: proposal.body["en"],
          authors: Contribution.authors(proposal),
          created_at: proposal.created_at,
          updated_at: proposal.updated_at,
          deleted_at: nil
        }
      end

      def self.authors(proposal)
        proposal.authors.map do |author|
          if author.instance_of?(Decidim::User) || author.instance_of?(Decidim::UserGroup)
            author.name
          elsif author.instance_of?(Decidim::Organization)
            author.reference_prefix
          elsif author.instance_of?(Decidim::Meetings::Meeting)
            author.reference
          end
        end
      end

      private

      def title_or_content
        errors.add :base, "Title or content must be present" if title.blank? && content.blank?
      end
    end
  end
end
