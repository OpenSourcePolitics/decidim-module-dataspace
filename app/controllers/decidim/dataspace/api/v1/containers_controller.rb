# frozen_string_literal: true

module Decidim
  module Dataspace
    class Api::V1::ContainersController < Api::V1::BaseController
      before_action :set_container, only: :show

      def index
        return resource_not_found("Containers") if Container.from_proposals.blank?

        render json: { containers: Container.from_proposals }, status: :ok
      end

      def show
        render json: @container, status: :ok
      end

      def set_container
        @container = Container.from_params(params[:reference])
        return resource_not_found("Container") unless @container

        @container
      end
    end
  end
end
