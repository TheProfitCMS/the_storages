class DelayedImageProcessor < Struct.new(:attached_file)
  def perform
    attached_file.build_base_images
  end
end