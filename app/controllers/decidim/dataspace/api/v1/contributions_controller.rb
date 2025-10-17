# frozen_string_literal: true
require 'uri'

module Decidim
  module Dataspace
    class Api::V1::ContributionsController < Api::V1::BaseController
      before_action :set_contribution, only: :show

      def index
        preferred_locale = params[:preferred_locale].presence || "en"
        contributions = Contribution.from_proposals(preferred_locale)
        return resource_not_found("Contributions") if contributions.blank?

        render json: contributions, status: :ok
      end

      def show
        render json: @contribution, status: :ok
      end

      private

      def set_contribution
        ref = CGI.unescape(params[:reference])
        preferred_locale = params[:preferred_locale].presence || "en"
        @contribution = Contribution.proposal(ref, preferred_locale)
        return resource_not_found("Contribution") unless @contribution

        @contribution
      end
    end
  end
end
