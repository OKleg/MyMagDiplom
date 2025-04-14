class Room < ApplicationRecord
  # has_rich_text :content

  has_many :operations

  validates_uniqueness_of :name
  scope :public_rooms, -> {where(is_private: false)}

  # Создание начальной версии документа
  after_create_commit { broadcast_append_to 'rooms' }


end
