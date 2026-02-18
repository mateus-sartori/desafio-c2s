class ScrapeTask < ApplicationRecord
  validates :url, :task_id, presence: true
  validates :url, format: { with: URI.regexp }

  enum :status, { pending: 0, processing: 1, finished: 2, failed: 3 }
end
