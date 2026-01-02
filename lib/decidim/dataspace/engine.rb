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
              resources :authors, only: [:index, :show], param: :reference
              resources :contributions, only: [:index, :show], param: :reference
            end
          end
        end
      end

      initializer "decidim_dataspace.mount_routes", before: :add_routing_paths do
        # Mount the engine routes to Decidim::Core::Engine because otherwise
        # they would not get mounted properly.
        Decidim::Proposals::Engine.routes.append do
          resources :proposals do
            collection do
              get "external_proposal/:reference", to: "proposals#external_proposal", param: :reference, as: :external_proposal
            end
          end
        end
      end

      initializer "dataspace-extends" do
        config.after_initialize do
          require "extends/controllers/decidim/proposals/proposals_controller_extends"
          require "extends/models/decidim/comments/comment_extends"
          require "extends/lib/decidim/core_extends"
        end
      end

      initializer "decidim_dataspace.add_customizations" do
        config.to_prepare do
          # Helper
          Decidim::Proposals::ProposalsHelper.class_eval do
            include Decidim::Proposals::ExternalProposalHelper
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
