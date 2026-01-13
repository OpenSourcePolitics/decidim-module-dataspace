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

      # get all the proposals with or without comments
      def self.from_proposals(preferred_locale, with_comments = "false", container = nil)
        proposals = Decidim::Proposals::Proposal.published
                                                .not_hidden
                                                .includes(:component)

        proposals = Contribution.filter_proposals_by_container(container, proposals) if container

        locale = "en"
        available_locales = proposals.first&.organization&.available_locales
        locale = preferred_locale if available_locales.present? && available_locales.include?(preferred_locale)

        return Contribution.proposals_and_comments(proposals, locale) if with_comments == "true"

        proposals.map do |proposal|
          Contribution.proposal_without_comment(proposal, locale)
        end
      end

      # get one contribution (proposal or comment)
      def self.get_one(params_reference, preferred_locale, with_comments = "false")
        contribution = Decidim::Proposals::Proposal.find_by(reference: params_reference) || Decidim::Comments::Comment.find_by(reference: params_reference)
        return nil unless contribution

        available_locales = contribution.organization.available_locales
        locale = available_locales.include?(preferred_locale) ? preferred_locale : "en"

        if contribution.is_a?(Decidim::Proposals::Proposal)
          # proposal with detailed comments
          return Contribution.proposal_with_comments(contribution, locale) if with_comments == "true"

          # proposal without detailed comments
          Contribution.proposal_without_comment(contribution, locale)
        else
          Contribution.comment(contribution, locale)
        end
      end

      # get proposals and their comments
      def self.proposals_and_comments(proposals, locale)
        proposals.all.map do |proposal|
          component = proposal.component
          comments = Contribution.comments(proposal, locale)
          [
            Decidim::Dataspace::ContributionPresenter.new(proposal).proposal_without_comment(component, locale), comments.flatten
          ]
        end.flatten
      end

      # get one proposal without detailed comments
      def self.proposal_without_comment(proposal, locale)
        component = proposal.component
        Decidim::Dataspace::ContributionPresenter.new(proposal).proposal_without_comment(component, locale)
      end

      # get one proposal with detailed comments
      def self.proposal_with_comments(proposal, locale)
        component = proposal.component
        Decidim::Dataspace::ContributionPresenter.new(proposal).proposal_with_comments(component, locale)
      end

      # get detailed comments of a proposal
      def self.comments(proposal, locale)
        proposal.comments.map do |comment|
          component = comment.component
          Decidim::Dataspace::ContributionPresenter.new(comment).comment(proposal, component, locale)
        end
      end

      # get one comment
      def self.comment(comment, locale)
        component = comment.component
        proposal = Decidim::Proposals::Proposal.find(comment.decidim_root_commentable_id)
        Decidim::Dataspace::ContributionPresenter.new(comment).comment(proposal, component, locale)
      end

      # get parent of a comment
      def self.parent(comment, proposal)
        comment.decidim_commentable_type == "Decidim::Comments::Comment" ? Decidim::Comments::Comment.find(comment.decidim_commentable_id).reference : proposal.reference
      end

      # get children of a comment
      def self.children(comment)
        children = Decidim::Comments::Comment.where(decidim_commentable_type: "Decidim::Comments::Comment", decidim_commentable_id: comment.id)
        return nil if children.blank?

        children.map(&:reference)
      end

      # get authors of a proposal
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

      def self.filter_proposals_by_container(container, proposals)
        participatory_space = Decidim::ParticipatoryProcess.find_by(reference: container) || Decidim::Assembly.find_by(reference: container)
        if participatory_space
          component_ids = participatory_space.components.where(manifest_name: "proposals").ids
          proposals = proposals.where(decidim_component_id: component_ids)
        end
        proposals
      end

      private

      def title_or_content
        errors.add :base, "Title or content must be present" if title.blank? && content.blank?
      end
    end
  end
end
