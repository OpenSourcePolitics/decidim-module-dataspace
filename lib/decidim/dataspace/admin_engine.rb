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

      def load_seed
        nil
      end
    end
  end
end
