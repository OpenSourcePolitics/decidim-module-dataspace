# frozen_string_literal: true

module Decidim
  module Dataspace
    class Api::V1::ContainersController < Api::V1::BaseController
      before_action :set_container, only: :show

      def index
        preferred_locale = params["preferred_locale"] || "en"
        containers = Container.from_proposals(preferred_locale)
        return resource_not_found("Containers") if containers.blank?

        render json: containers, status: :ok
      end

      def show
        render json: @container, status: :ok
      end

      def set_container
        ref = CGI.unescape(params[:reference])
        preferred_locale = params["preferred_locale"] || "en"
        @container = Container.from_params(ref, preferred_locale)
        return resource_not_found("Container") unless @container

        @container
      end
    end
  end
end
