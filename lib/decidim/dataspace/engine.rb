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
      end

      initializer "Dataspace.webpacker.assets_path" do
        Decidim.register_assets_path File.expand_path("app/packs", root)
      end
    end
  end
end
