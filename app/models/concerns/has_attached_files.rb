module TheStorages
  module HasAttachedFiles
    extend ActiveSupport::Concern

    included do
      has_many :all_attached_files, class_name: :AttachedFile, foreign_key: :user_id
    end

    def recalculate_all_attached_files
      af = all_attached_files.pluck(:attachment_file_size)
      self.all_attached_files_count = af.count
      self.all_attached_files_size  = af.sum
      save
    end
  end
end
