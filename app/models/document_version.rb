class DocumentVersion < ApplicationRecord
  belongs_to :room
  has_many :operations

end
