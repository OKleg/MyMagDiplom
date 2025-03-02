class Operation < ApplicationRecord
  after_create :transform

  private

  def transform
    Rails.logger.info "Operation create #{self}"
    theirs = Operation.where(version >= :version)
    TransformationService.call(theirs, self)
  end

end
