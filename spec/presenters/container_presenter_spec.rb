# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Dataspace
    describe ContainerPresenter do
      let!(:process) { create(:participatory_process) }
      let!(:locale) { "en" }

      describe "container method" do
        let(:presenter) { ContainerPresenter.new(process) }

        it "returns a hash with container informations" do
          method_call = presenter.container(locale)
          expect(method_call.class).to eq(Hash)
          expect(method_call.size).to eq(8)
          expect(method_call[:reference]).to eq(process.reference)
          expect(method_call[:description]).to eq(translated_attribute(process.description))
        end
      end
    end
  end
end
