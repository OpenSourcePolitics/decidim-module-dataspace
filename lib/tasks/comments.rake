# frozen_string_literal: true

namespace :comments do
  desc "Set reference to comments"
  task add_reference: :environment do
    comments = Decidim::Comments::Comment.where(reference: nil)
    p "begin to add reference to #{comments.size} comments"
    count = 0
    comments.find_each(batch_size: 100) do |comment|
      # rubocop:disable Rails/SkipsModelValidations
      comment.update_column(:reference, Decidim.reference_generator.call(comment, comment.component))
      # rubocop:enable Rails/SkipsModelValidations
      count += 1 if comment.reference.present?
    end
    p "Comments updated: #{count}"
  end
end
