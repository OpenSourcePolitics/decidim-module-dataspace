# frozen_string_literal: true

module Decidim
  module Dataspace
    class ContainerPresenter
      def initialize(container)
        @container = container
      end

      def container(locale)
        {
          "reference": @container.reference,
          "source": Decidim::ResourceLocatorPresenter.new(@container).url,
          "name": @container.title[locale],
          "description": @container.description[locale],
          "metadata": {},
          "created_at": @container.created_at,
          "updated_at": @container.updated_at,
          "deleted_at": nil
        }
      end
    end
  end
end
