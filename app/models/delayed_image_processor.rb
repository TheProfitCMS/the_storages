class DelayedImageProcessor < Struct.new(:attached_file)
  def perform
    sleep 10
    attached_file.build_base_images
  end
end