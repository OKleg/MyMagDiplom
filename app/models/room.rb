class Room < ApplicationRecord
  # has_rich_text :content

  has_many :document_versions
  has_many :operations, through: :document_versions

  validates_uniqueness_of :name
  scope :public_rooms, -> {where(is_private: false)}

  # Создание начальной версии документа
  after_create :create_initial_version
  after_create_commit { broadcast_append_to 'rooms' }

  def create_initial_version
    document_versions.create!( version_number: 0)
  end
end
