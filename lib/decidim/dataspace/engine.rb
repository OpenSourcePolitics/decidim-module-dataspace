# frozen_string_literal: true

require "rails"
require "decidim/core"

module Decidim
  module Dataspace
    # This is the engine that runs on the public interface of dataspace.
    class Engine < ::Rails::Engine
      isolate_namespace Decidim::Dataspace

      routes do
        # Add engine routes here
        # resources :dataspace
        # root to: "dataspace#index"

        # we want routes like api/v1/data for controllers Api::v1::DataController
        namespace :api, defaults: { format: :json } do
          namespace :v1 do
            scope :data do
              get "/", to: "data#index"
              resources :containers, only: [:index, :show], param: :reference
              resources :authors, only: [:index, :show, :create], param: :reference
              resources :contributions, only: [:index, :show], param: :reference
            end
          end
        end
      end

      initializer "dataspace.mount_routes" do
        Decidim::Core::Engine.routes do
          mount Decidim::Dataspace::Engine => "/"
        end
      end

      initializer "Dataspace.webpacker.assets_path" do
        Decidim.register_assets_path File.expand_path("app/packs", root)
      end
    end
  end
end
