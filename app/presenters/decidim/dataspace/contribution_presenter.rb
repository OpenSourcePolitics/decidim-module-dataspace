# frozen_string_literal: true

module Decidim
  module Dataspace
    class ContributionPresenter
      def initialize(contribution)
        @contribution = contribution
      end

      def comment(proposal, component, locale)
        {
          reference: @contribution.reference,
          source: Decidim::ResourceLocatorPresenter.new(proposal).url,
          container: component.participatory_space_type.constantize.find(component.participatory_space_id).reference,
          locale:,
          title: nil,
          content: @contribution.body[locale] || @contribution.body["en"],
          authors: @contribution.author.name,
          parent: Decidim::Dataspace::Contribution.parent(@contribution, proposal),
          children: Decidim::Dataspace::Contribution.children(@contribution),
          metadata: { depth: @contribution.depth, alignment: @contribution.alignment },
          created_at: @contribution.created_at,
          updated_at: @contribution.updated_at,
          deleted_at: @contribution.deleted_at
        }
      end

      def proposal_with_comments(component, locale)
        {
          reference: @contribution.reference,
          source: Decidim::ResourceLocatorPresenter.new(@contribution).url,
          container: component.participatory_space_type.constantize.find(component.participatory_space_id).reference,
          locale:,
          title: @contribution.title[locale] || @contribution.title["en"],
          content: @contribution.body[locale] || @contribution.body["en"],
          authors: Decidim::Dataspace::Contribution.authors(@contribution),
          parent: nil,
          children: Decidim::Dataspace::Contribution.comments(@contribution, locale),
          metadata: { state: { withdrawn: @contribution.withdrawn?, emendation: @contribution.emendation?, state: @contribution.state } },
          created_at: @contribution.created_at,
          updated_at: @contribution.updated_at,
          deleted_at: nil # does not exist in proposal
        }
      end

      def proposal_without_comment(component, locale)
        {
          reference: @contribution.reference,
          source: Decidim::ResourceLocatorPresenter.new(@contribution).url,
          container: component.participatory_space_type.constantize.find(component.participatory_space_id).reference,
          locale:,
          title: @contribution.title[locale] || @contribution.title["en"],
          content: @contribution.body[locale] || @contribution.body["en"],
          authors: Decidim::Dataspace::Contribution.authors(@contribution),
          parent: nil,
          children: @contribution.comments.map(&:reference),
          metadata: { state: { withdrawn: @contribution.withdrawn?, emendation: @contribution.emendation?, state: @contribution.state } },
          created_at: @contribution.created_at,
          updated_at: @contribution.updated_at,
          deleted_at: nil
        }
      end
    end
  end
end
