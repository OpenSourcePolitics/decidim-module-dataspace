# frozen_string_literal: true

module Decidim
  module Dataspace
    class Api::V1::AuthorsController < Api::V1::BaseController
      before_action :set_author, only: :show

      def index
        preferred_locale = params[:preferred_locale].presence || "en"
        authors = Author.from_proposals(preferred_locale)
        return resource_not_found("Authors") if authors.blank?

        render json: authors, status: :ok
      end

      def show
        render json: @author, status: :ok
      end

      def set_author
        ref = CGI.unescape(params[:reference])
        preferred_locale = params[:preferred_locale].presence || "en"
        @author = Author.proposal_author(ref, preferred_locale)
        return resource_not_found("Author") unless @author

        @author
      end
    end
  end
end
