# frozen_string_literal: true

module Decidim
  module Dataspace
    class Api::V1::ContainersController < Api::V1::BaseController
      before_action :set_container, only: :show

      def index
        render json: { containers: Decidim::Dataspace::Container.all.map { |container| render_container(container) } }, status: :ok
      end

      def show
        render json: render_container(@container), status: :ok
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

      def set_container
        interoperable = Decidim::Dataspace::Interoperable.find_by(reference: params[:reference])
        return resource_not_found("Container") unless interoperable

        @container = Decidim::Dataspace::Container.find_by(interoperable_id: interoperable.id)

        return resource_not_found("Container") unless @container

        @container
      end
    end
  end
end
