# frozen_string_literal: true

module Decidim
  module Dataspace
    class Api::V1::AuthorsController < Api::V1::BaseController
      before_action :set_author, only: :show

      def index
        return resource_not_found("Authors") if Author.from_proposals.blank?

        render json: { authors: Author.from_proposals }, status: :ok
      end

      def show
        render json: @author, status: :ok
      end

      def set_author
        @author = Author.proposal_author(params[:reference])
        return resource_not_found("Author") unless @author

        @author
      end
    end
  end
end
