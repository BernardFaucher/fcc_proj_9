class Reply < ApplicationRecord
    validates :text, presence: true
    validates :topic_id, presence: true
    belongs_to :topic

    def _id
        self.id
    end

    def created_on
        self.created_at
    end
end
