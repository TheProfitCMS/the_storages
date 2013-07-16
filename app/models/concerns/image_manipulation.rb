module ImageManipulation
  extend ActiveSupport::Concern

  # HELPERS
  def landscape? image
    image[:width] > image[:height]
  end

  def portrait? image
    image[:width] < image[:height]
  end

  # Fu
  def rotate_attached_image angle
    # rotate src
    src   = path
    image = MiniMagick::Image.open(src)
    image.rotate angle
    image.write  src

    # base
    build_base_image
    put_watermark_on_base_image

    # preview
    build_correct_preview
  end

  def rotate_left
    rotate_attached_image "-90"
  end

  def rotate_right
    rotate_attached_image "90"
  end

  def resize_to_larger_side image, side_size
    if image[:width] > side_size
      landscape?(image)             ?
      image.resize("#{side_size}x") :
      image.resize("x#{side_size}")
    end

    image
  end

  # IMAGE CROP
  def crop_image name = :cropped_image, x0 = 0, y0 = 0, w = 100, h = 100, img_w = nil
    src      = path
    base     = path :base
    cropped  = path name

    image = MiniMagick::Image.open base
    
    img_w ||= image[:width]
    scale   = image[:width].to_f/img_w.to_f

    w = (w.to_f * scale).to_i
    h = (h.to_f * scale).to_i

    x_shift = (x_shift.to_f * scale).to_i
    y_shift = (y_shift.to_f * scale).to_i

    image.crop "#{w}x#{h}+#{x0}+#{y0}"
    image.write cropped
  end
end