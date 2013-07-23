module AttachmentProcessing
  extend ActiveSupport::Concern

  included do
    attr_accessor :image_processing
    before_create :set_processing_flags
    after_commit  :delayed_image_processing

    has_attached_file :attachment,
                      default_url: ":rails_root/public/system/uploads/default/:style-missing.jpg",
                      path:        ":rails_root/public/system/storages/:storage_type/:storage_id/:style/:filename",
                      url:         "/system/storages/:storage_type/:storage_id/:style/:filename"

    validates_attachment_size :attachment,
      in: 10.bytes..5.megabytes,
      message: I18n.translate('the_storages.validation.attachment_file_size')

    validates :attachment_file_name,
      uniqueness: {
        scope: [:user_id, :storage_type, :storage_id],
        message: I18n.translate('the_storages.validation.uniq_attachment_file_name')
      }
  end

  def set_processing_flags
    if is_image?
      self.processing       = :processing
      self.image_processing = true
    end
  end

  # DELAYED JOB
  def delayed_image_processing
    if is_image? && image_processing
      self.image_processing = false
      job = DelayedImageProcessor.new(self)

      # Run Job!
      job.perform
      # Delayed::Job.enqueue job, queue: :image_processing, run_at: Proc.new { 10.seconds.from_now }
    end
  end
end