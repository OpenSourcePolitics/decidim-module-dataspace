# frozen_string_literal: true

module Decidim
  module Dataspace
    class Api::V1::ContributionsController < Api::V1::BaseController
      before_action :set_contribution, only: :show

      def index
        render json: { contributions: Decidim::Dataspace::Contribution.all.map { |contribution| render_contribution(contribution) } }
      end

      def show
        render json: render_contribution(@contribution)
      end

      private

      def render_contribution(contribution)
        {
          reference: contribution.reference,
          source: contribution.source,
          container: contribution.container.reference,
          locale: contribution.locale,
          title: contribution.title,
          content: contribution.content,
          authors: contribution.authors&.map(&:reference),
          metadata: contribution.metadata,
          parent: contribution.parent&.reference,
          created_at: contribution.created_at,
          updated_at: contribution.updated_at,
          deleted_at: contribution.deleted_at
        }
      end

      def set_contribution
        interoperable = Decidim::Dataspace::Interoperable.find_by(reference: params[:reference])
        return resource_not_found("Contribution") unless interoperable

        @contribution = Decidim::Dataspace::Contribution.find_by(interoperable_id: interoperable.id)
        return resource_not_found("Contribution") unless @contribution

        @contribution
      end
    end
  end
end
