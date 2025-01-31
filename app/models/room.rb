class Room < ApplicationRecord
  has_rich_text :content

  validates_uniqueness_of :name
  scope :public_rooms, -> {where(is_private: false)}
  after_create_commit { broadcast_append_to 'rooms' }

end
