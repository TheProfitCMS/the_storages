module AttachmentProcessing
  extend ActiveSupport::Concern

  def set_processing_flags
    if is_image?
      self.processing       = :processing
      self.image_processing = true
    end
  end

  # DELAYED JOB
  def delayed_file_processing
    if is_image? && image_processing
      self.image_processing = false
      job = DelayedImageProcessor.new(self)
      job.perform
      # Delayed::Job.enqueue job, queue: :image_processing, run_at: Proc.new { 10.seconds.from_now }
    else
      # if it's not image
      # Upload file and recalculate
      recalculate_storage_counters!
    end
  end
end