module ActAsStorage
  extend ActiveSupport::Concern

  included do
    has_many :attached_files,  as: :storage

    # before_update :recalculate_storage_counters
    # after_update  :recalculate_user_counters
    # after_destroy :recalculate_user_counters
  end

  def recalculate_storage_counters
    af = attached_files.pluck(:attachment_file_size)
    self.storage_files_count = af.count
    self.storage_files_size  = af.sum
    save
  end

  def recalculate_user_counters
    user = try(:user)
    user.recalculate_all_attached_files if user
  end
end