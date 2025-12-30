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

        return Contribution.proposals_with_comments(proposals, locale) if with_comments == "true"

        proposals.all.map do |proposal|
          Contribution.proposal_without_comment(proposal, locale)
        end
      end

      # get one proposal with or without detailed comments
      def self.proposal(params_reference, preferred_locale, with_comments = "false")
        proposal = Decidim::Proposals::Proposal.find_by(reference: params_reference)
        return nil unless proposal

        available_locales = proposal.organization.available_locales
        locale = available_locales.include?(preferred_locale) ? preferred_locale : "en"

        return Contribution.proposal_with_comments(proposal, locale) if with_comments == "true"

        Contribution.proposal_without_comment(proposal, locale)
      end

      # get proposals with comments
      def self.proposals_with_comments(proposals, locale)
        proposals.all.map do |proposal|
          component = proposal.component
          comments = Contribution.comments(proposal, locale)
          [
            {
              reference: proposal.reference,
              source: Decidim::ResourceLocatorPresenter.new(proposal).url,
              container: component.participatory_space_type.constantize.find(component.participatory_space_id).reference,
              locale:,
              title: proposal.title[locale] || proposal.title["en"],
              content: proposal.body[locale] || proposal.body["en"],
              authors: Contribution.authors(proposal),
              parent: nil,
              children: comments.map { |comment| comment[:reference] },
              metadata: { state: { withdrawn: proposal.withdrawn?, emendation: proposal.emendation?, state: proposal.state } },
              created_at: proposal.created_at,
              updated_at: proposal.updated_at,
              deleted_at: nil # does not exist in proposal
            }, comments.flatten
          ]
        end.flatten
      end

      # get proposal without detailed comments
      def self.proposal_without_comment(proposal, locale)
        component = proposal.component
        {
          reference: proposal.reference,
          source: Decidim::ResourceLocatorPresenter.new(proposal).url,
          container: component.participatory_space_type.constantize.find(component.participatory_space_id).reference,
          locale:,
          title: proposal.title[locale] || proposal.title["en"],
          content: proposal.body[locale] || proposal.body["en"],
          authors: Contribution.authors(proposal),
          parent: nil,
          children: proposal.comments.map { |comment| "#{proposal.reference}-#{comment.id}" },
          metadata: { state: { withdrawn: proposal.withdrawn?, emendation: proposal.emendation?, state: proposal.state } },
          created_at: proposal.created_at,
          updated_at: proposal.updated_at,
          deleted_at: nil # does not exist in proposal
        }
      end

      # get detailed comments of a proposal
      def self.comments(proposal, locale)
        proposal.comments.map do |comment|
          component = comment.component
          {
            reference: "#{proposal.reference}-#{comment.id}",
            source: Decidim::ResourceLocatorPresenter.new(proposal).url,
            container: component.participatory_space_type.constantize.find(component.participatory_space_id).reference,
            locale:,
            title: nil,
            content: comment.body[locale] || comment.body["en"],
            authors: comment.author.name,
            parent: Contribution.parent(comment, proposal),
            children: Contribution.children(comment, proposal),
            metadata: { depth: comment.depth, alignment: comment.alignment },
            created_at: comment.created_at,
            updated_at: comment.updated_at,
            deleted_at: comment.deleted_at
          }
        end
      end

      # get parent of a comment
      def self.parent(comment, proposal)
        comment.decidim_commentable_type == "Decidim::Comments::Comment" ? "#{proposal.reference}-#{comment.decidim_commentable_id}" : proposal.reference
      end

      # get children of a comment
      def self.children(comment, proposal)
        children = Decidim::Comments::Comment.where(decidim_commentable_type: "Decidim::Comments::Comment", decidim_commentable_id: comment.id)
        return nil if children.blank?

        children.map { |child| "#{proposal.reference}-#{child.id}" }
      end

      # get one proposal with detailed comments
      def self.proposal_with_comments(proposal, locale)
        component = proposal.component
        {
          reference: proposal.reference,
          source: Decidim::ResourceLocatorPresenter.new(proposal).url,
          container: component.participatory_space_type.constantize.find(component.participatory_space_id).reference,
          locale:,
          title: proposal.title[locale] || proposal.title["en"],
          content: proposal.body[locale] || proposal.body["en"],
          authors: Contribution.authors(proposal),
          parent: nil,
          children: Contribution.comments(proposal, locale),
          metadata: { state: { withdrawn: proposal.withdrawn?, emendation: proposal.emendation?, state: proposal.state } },
          created_at: proposal.created_at,
          updated_at: proposal.updated_at,
          deleted_at: nil
        }
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
