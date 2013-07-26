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
  def rotate_image src, dest, angle
    img = MiniMagick::Image.open(src)
    img.rotate(angle)
    img.write(dest)
  end

  def rotate_attached_image angle
    src = path
    rotate_image(src,src,angle)
    refresh_base_image
  end

  def rotate_left
    rotate_attached_image "-90"
  end

  def rotate_right
    rotate_attached_image "90"
  end

  def resize_to_larger_side image, side_size
    if image[:width] > side_size.to_i
      landscape?(image)             ?
      image.resize("#{side_size}x") :
      image.resize("x#{side_size}")
    end

    image
  end

  def resize_to_larger_side! src, side_size
    image = MiniMagick::Image.open(src)
    image = resize_to_larger_side(image, side_size)
    image.write src
  end

  # IMAGE CROP
  def crop_image src, dest, x0 = 0, y0 = 0, w = 100, h = 100, scale = 1
    image = MiniMagick::Image.open src

    x_shift = (x0.to_f * scale).to_i
    y_shift = (y0.to_f * scale).to_i

    w = (w.to_f * scale).to_i
    h = (h.to_f * scale).to_i

    image.crop "#{w}x#{h}+#{x_shift}+#{y_shift}"
    image.write dest  
  end
end