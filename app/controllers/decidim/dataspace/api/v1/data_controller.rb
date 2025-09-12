# frozen_string_literal: true

module Decidim
  module Dataspace
    class Api::V1::DataController < Api::V1::BaseController
      def index
        render json:
          {
            containers: Container.from_proposals,
            contributions: Contribution.from_proposals,
            authors: Author.from_proposals
          }, status: :ok
      end
    end
  end
end
