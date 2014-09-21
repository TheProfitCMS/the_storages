module TheStorages
  module Storage
    extend ActiveSupport::Concern

    included do
      has_many :attached_files, as: :storage
    end

    def recalculate_storage_counters!
      af = attached_files.pluck(:attachment_file_size)
      self.storage_files_count = af.count
      self.storage_files_size  = af.sum
      save

      self.try(:user).try(:recalculate_all_attached_files!)
    end
  end
end
