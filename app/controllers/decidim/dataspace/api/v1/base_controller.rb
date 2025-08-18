# frozen_string_literal: true

module Decidim
  module Dataspace
    class Api::V1::BaseController < ActionController::API
      # skip_before_action :verify_authenticity_token

      rescue_from ActiveRecord::RecordNotFound, with: :not_found
      rescue_from ActiveRecord::RecordInvalid, with: :validation_error

      private

      def not_found(exception)
        render json: { error: "Resource not found", message: exception.message }, status: :not_found
      end

      def validation_error(exception)
        render json: { error: "Invalid record", message: exception.message }, status: :unprocessable_entity
      end

      def resource_not_found(resource)
        render json: { error: "#{resource} not found" }, status: :not_found
      end
    end
  end
end
