# frozen_string_literal: true

require "decidim/components/namer"
require "decidim/core/test/factories"

FactoryBot.define do
  # factory :dataspace_component, parent: :component do
  #  name { Decidim::Components::Namer.new(participatory_space.organization.available_locales, :dataspace).i18n_name }
  #  manifest_name :dataspace
  #  participatory_space { create(:participatory_process, :with_steps) }
  # end

  # Add engine factories here
  factory :interoperable, class: "Decidim::Dataspace::Interoperable" do
    reference { "I01" }
    source { "https://example.com/" }
    deleted_at { nil }
    metadata { {} }

    trait :reference_nil do
      reference { nil }
    end

    trait :source_nil do
      source { nil }
    end
  end

  factory :container, class: "Decidim::Dataspace::Container" do
    name { "Space 1" }
    description { "This is the first participatory space.\nIt allows users to contribute and discuss various topics." }
    reference { "B01" }
    source { "https://example.com" }
    deleted_at { nil }
    metadata { { "type": "participatory_process", "visibility": "public", "status": "published" } }
  end

  factory :author_one, class: "Decidim::Dataspace::Author" do
    name { "Jane Doe" }
    reference { "A01" }
    source { "https://example.com/account/janedoe" }
  end

  factory :author_two, class: "Decidim::Dataspace::Author" do
    name { "John Smith" }
    reference { "A02" }
    source { "https://example.com/account/johnsmith" }
  end

  factory :contribution, class: "Decidim::Dataspace::Contribution" do
    sequence(:title) { |n| "Contribution #{n}" }
    sequence(:content) { |n| "Contenu de la contribution #{n}\nsur plusieurs lignes" }
    sequence(:reference) { |n| "C0#{n}" }
    sequence(:source) { |n| "https://example.com/contribution/#{n}" }
    metadata { { "type": "proposal", "status": "published" } }
    deleted_at { 1.day.ago }
    locale { "fr" }
    association :container

    trait :contrib_one do
      after :create do |contribution, _evaluator|
        contribution.authors << create(:author_one)
        contribution.save!
      end
    end

    trait :contrib_two do
      after :create do |contribution|
        contribution.authors << create(:author_two)
        contribution.save!
      end
    end

    trait :with_two_authors do
      after :create do |contribution|
        contribution.authors << create(:author_one)
        contribution.authors << create(:author_two)
        contribution.save!
      end
    end

    trait :with_parent do
      after :create do |contribution|
        contrib = create(:contribution, :contrib_one)
        contribution.parent = contrib
        contribution.save!
        contrib.children << contribution
        contrib.save!
      end
    end
  end
end
