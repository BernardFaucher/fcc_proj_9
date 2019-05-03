class Topic < ApplicationRecord
    validates :text, presence: true
    validates :board, presence: true
    has_many :replies

    def self.latest_threads_in_board(board)
        Topic.where({board: board}).order(created_at: :desc).limit(10)
    end

    def _id
        self.id
    end

    def created_on
        self.created_at
    end

    def bumped_on
        self.updated_at
    end
end
