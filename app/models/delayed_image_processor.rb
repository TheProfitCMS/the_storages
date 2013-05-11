class DelayedImageProcessor < Struct.new(:attached_file)
  def landscape? image
    image[:width] > image[:height]
  end

  def portrait? image
    image[:width] < image[:height]
  end

  def perform
    sleep 100

    # file path
    src      = attached_file.path
    original = attached_file.styled_path(:original)
    preview  = attached_file.styled_path(:preview)

    # original
    image = MiniMagick::Image.open src
    image.auto_orient
    landscape?(image) ? image.resize('800x') : image.resize('x800') if image[:width] > 800
    image.strip
    image.write original

    # preview
    image = MiniMagick::Image.open original
    image.resize "100x100!"
    image.write preview

    # delete source
    image = MiniMagick::Image.open original
    image.write src

    # set process state
    src_size = File.size?(src)
    attached_file.update(processing: :finished, attachment_file_size: src_size)
  end
end

# def log msg
#   @log_file ||= "#{Rails.root.to_s}/DJ.log"
#   system("echo #{msg} >> #{@log_file}")
# end

# def enqueue(job)
#   # log :enqueue
# end

# def before(job)
#   # log :before
# end

# def after(job)
#   # log :after
# end

# def success(job)
#   # log :success
# end

# def error(job, exception)
#   # log :error
# end

# def failure
#   log :failure
# end

# image = MiniMagick::Image.open AttachedFile.last.path
# image[:width]
# image[:height]
# image.auto_orient
# image.resize "800x"
# image.resize "x600"
# image.format "gif"
# c.rotate "-90>"
# c.gravity "center"
# c.compose "Over" # OverCompositeOp
# c.geometry "+20+20" # copy second_image onto first_image from (20, 20)
# image[:width]               # will get the width (you can also use :height and :format)
# image["EXIF:BitsPerSample"] # It also can get all the EXIF tags
# image["%m:%f %wx%h"] 
# image.trim

# def resize_and_crop_image(img, w, h)

#     img_w = img[:width].to_f
#     img_h = img[:height].to_f

#     logger.debug "image w #{img_w} image h #{img_h}"

#     #scale image to correct size
#     w_ratio =  w / img_w
#     h_ratio =  h / img_h

#     logger.debug "w ratio #{w_ratio} h ratio #{h_ratio}"

#     scale = 1

#     if (img_h > h && img_w > w)
#     scale = h_ratio > w_ratio ? h_ratio : w_ratio
#     else
#     scale = h_ratio < w_ratio ? h_ratio : w_ratio
#     end

#     logger.debug "scale to #{scale * 100}%"
#     img.scale "#{scale * 100}%"

#     img_w = img[:width].to_f
#     img_h = img[:height].to_f
#     logger.debug "image w #{img_w} image h #{img_h}"

#     y_shift = ((img_h - h) / 2).abs
#     x_shift = ((img_w - w) / 2).abs
  
#     logger.debug "x shift #{x_shift} y shift #{y_shift}"

#     img.crop "#{w}x#{h}+#{x_shift}+#{y_shift}"
#     #img.resize "#{w}x#{h}"

#     img

#   end

# def update_attributes(att)
 
#   scaled_img = Magick::ImageList.new(self.photo.path)
#   orig_img = Magick::ImageList.new(self.photo.path(:original))
#   scale = orig_img.columns.to_f / scaled_img.columns
 
#   args = [ att[:x1], att[:y1], att[:width], att[:height] ]
#   args = args.collect { |a| a.to_i * scale }
 
#   orig_img.crop!(*args)
#   orig_img.write(self.photo.path(:original))
 
#   self.photo.reprocess!
#   self.save
 
#   super(att)
# end


# # DELAYED processes
# def process_image    
#   # job = DelayedImageProcessor.new(self)
#   # Delayed::Job.enqueue job
#   attached_file = self

#   log "JOb start"
#   sleep 10

#   image = MiniMagick::Image.open(attached_file.path)
#   image.resize "100x100!"
#   image.write attached_file.styled_path(:preview)

#   log "AttachedId", attached_file.id

#   AttachedFile.update(attached_file.id, processing: :finished)

#   log "JOb finished"
# end

# handle_asynchronously :process_image, run_at: Proc.new { 5.seconds.from_now }