# frozen_string_literal: true

module Decidim
  module Dataspace
    # This is the engine that runs on the public interface of `Dataspace`.
    class AdminEngine < ::Rails::Engine
      isolate_namespace Decidim::Dataspace::Admin

      paths["db/migrate"] = nil
      paths["lib/tasks"] = nil

      routes do
        # Add admin engine routes here
        # resources :dataspace do
        #   collection do
        #     resources :exports, only: [:create]
        #   end
        # end
        # root to: "dataspace#index"
      end

      initializer "decidim-dataspace.add_proposal_component_settings" do
        languages = Rails.application.secrets.dig(:decidim, :available_locales)
        default_language = Rails.application.secrets.dig(:decidim, :default_locale)
        manifest = Decidim.find_component_manifest("proposals")
        manifest.settings(:global) do |settings|
          settings.attribute :add_integration, type: :boolean, default: false
          settings.attribute :integration_url, type: :string
          settings.attribute :preferred_locale, type: :select, default: default_language, choices: languages
        end
      end

      def load_seed
        nil
      end
    end
  end
end
