# frozen_string_literal: true

module Decidim
  module Dataspace
    class Api::V1::AuthorsController < Api::V1::BaseController
      before_action :set_author, only: :show

      def index
        render json: { authors: Decidim::Dataspace::Author.all.map { |author| render_author(author) } }, status: :ok
      end

      def show
        render json: render_author(@author), status: :ok
      end

      private

      def render_author(author)
        {
          reference: author.reference,
          name: author.name,
          source: author.source
        }
      end

      def set_author
        interoperable = Decidim::Dataspace::Interoperable.find_by(reference: params[:reference])
        return resource_not_found("Author") unless interoperable

        @author = Decidim::Dataspace::Author.find_by(interoperable_id: interoperable.id)
        return resource_not_found("Author") unless @author

        @author
      end
    end
  end
end
