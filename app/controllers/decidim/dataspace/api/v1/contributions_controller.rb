# frozen_string_literal: true

module Decidim
  module Dataspace
    class Api::V1::ContributionsController < Api::V1::BaseController
      before_action :set_contribution, only: :show

      def index
        return resource_not_found("Contributions") if Contribution.from_proposals.blank?

        render json: { contributions: Contribution.from_proposals }, status: :ok
      end

      def show
        render json: @contribution, status: :ok
      end

      private

      def set_contribution
        @contribution = Contribution.proposal(params[:reference])
        return resource_not_found("Contribution") unless @contribution

        @contribution
      end
    end
  end
end
