# frozen_string_literal: true

module Decidim
  module Dataspace
    class Api::V1::DataController < Api::V1::BaseController
      def index
        render json:
          {
            containers: Decidim::Dataspace::Container.all.map { |container| render_container(container) },
            contributions: Decidim::Dataspace::Contribution.all.map { |contribution| render_contribution(contribution) },
            authors: Decidim::Dataspace::Author.all.map { |author| render_author(author) }
          }, status: :ok
      end

      private

      def render_container(container)
        {
          "reference": container.reference,
          "source": container.source,
          "name": container.name,
          "description": container.description,
          "metadata": container.metadata,
          "created_at": container.created_at,
          "updated_at": container.updated_at,
          "deleted_at": container.deleted_at
        }
      end

      def render_contribution(contribution)
        {
          "reference": contribution.reference,
          "source": contribution.source,
          "container": contribution.container.reference,
          "locale": contribution.locale,
          "title": contribution.title,
          "content": contribution.content,
          "authors": contribution.authors&.map(&:reference),
          "metadata": contribution.metadata,
          "parent": contribution.parent&.reference,
          "created_at": contribution.created_at,
          "updated_at": contribution.updated_at,
          "deleted_at": contribution.deleted_at
        }
      end

      def render_author(author)
        {
          reference: author.reference,
          name: author.name,
          source: author.source
        }
      end
    end
  end
end
