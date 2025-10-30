# frozen_string_literal: true

module Decidim
  module Dataspace
    class Api::V1::DataController < Api::V1::BaseController
      def index
        locale = params[:preferred_locale].presence || "en"
        render json:
          {
            containers: Container.from_proposals(locale),
            contributions: Contribution.from_proposals(locale),
            authors: Author.from_proposals(locale)
          }, status: :ok
      end
    end
  end
end
