class DelayedImageProcessor < Struct.new(:attached_file)
  def perform
    attached_file.build_base_images
    recalculate_storage_counters!
  end
end