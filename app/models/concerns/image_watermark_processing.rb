# encoding: UTF-8
module ImageWatermarkProcessing
  # CONSTANTS
  SITE_NAME = 'open-cook.ru'
  TITLE     = 'Открытая кухня Анны Нечаевой'

  def watermark_dir_path
    root_path = Rails.root.to_s
    dir_path  = "#{root_path}/public/uploads/watermarks"
    FileUtils.mkdir_p dir_path
    dir_path
  end

  def watermark_canvas_path style = :landscape
    "#{watermark_dir_path}/watermark_#{style}_canvas.png"
  end

  def watermark_path style = :landscape
    "#{watermark_dir_path}/watermark_#{style}.png"
  end

  def watermark_font
    path = "#{Rails.root.to_s}/vendor/fonts/georgia_italic.ttf"
    File.exists?(path) ? path : 'Times-Roman'
  end

  # HELPERS
  def landscape? image
    image[:width] > image[:height]
  end

  def portrait? image
    image[:width] < image[:height]
  end

  # WATERMARKS
  def create_watermark_canvas opts = {}
    opts[:type] ||= :landscape
    size          = opts[:type].to_sym == :landscape  ? '800x50' : '50x800'
    wm_canvas     = watermark_canvas_path(opts[:type])
    return false  if File.exists? wm_canvas
    Cocaine::CommandLine.new("convert", "-size #{size} xc:transparent #{wm_canvas}").run
    true
  end
  
  def create_watermark opts = {}
    opts[:type] ||=  :landscape
    watermark     =  watermark_path(opts[:type])
    return false  if File.exists? watermark
    
    # text params
    angle    = opts[:type].to_sym == :landscape ? 0 : -90
    rotate   = "rotate #{angle}"
    
    text     = "#{SITE_NAME}   #{TITLE}"
    bt       = "fill black #{rotate} text 0,12 '#{text}'"
    wt       = "fill white text 1,11 '#{text}'"
    
    fs       = "-font #{watermark_font} -pointsize 22"
    put_text = "-draw \"gravity center #{bt} #{wt}\""

    wm_canvas = watermark_canvas_path(opts[:type])
    Cocaine::CommandLine.new("convert", "#{wm_canvas} #{fs} #{put_text} -trim #{watermark}").run
    true
  end

  def build_watermarks
    create_watermark_canvas(type: :landscape)
    create_watermark_canvas(type: :portrait)

    create_watermark(type: :landscape)
    create_watermark(type: :portrait)
  end

  def put_watermark_on_main_image
    main        = path :main
    watermarked = path :watermarked
    image       = MiniMagick::Image.open main

    # top    = north
    # bottom = south
    # right  = east
    # left   = west

    watermark = watermark_path
    position  = :south
    x_shift   = "+0"
    y_shift   = "+10"
    
    if portrait?(image)
      watermark =  watermark_path(:portrait)
      position  = :east
      x_shift   = "+10"
      y_shift   = "+0"
    end

    stick   = "-gravity #{position}"
    shift   = "-geometry #{x_shift}#{y_shift}"
    opacity = "-dissolve 80%"

    Cocaine::CommandLine.new("composite", " #{stick} #{shift} #{opacity} #{watermark} #{main} #{watermarked}").run
    watermarked
  end

  # IMAGE PROCESSING
  def build_correct_preview
    main     = path :main
    preview  = path :preview
    
    image = MiniMagick::Image.open main

    min_size = image[:width]
    shift    = { x: 0, y: 0}
    
    if landscape?(image)
      min_size  = image[:height]
      shift[:x] = (image[:width] - min_size) / 2
    elsif portrait?(image)
      min_size = image[:width]
      shift[:y] = (image[:height] - min_size) / 2
    end    
    
    x0 = shift[:x]
    y0 = shift[:y]
    w  = h = min_size

    image.crop "#{w}x#{h}+#{x0}+#{y0}"
    image.resize "100x100!"
    image.write preview
  end

  def build_main_image
    src  = path
    main = path :main

    image = MiniMagick::Image.open src
    image.auto_orient
    landscape?(image) ? image.resize('800x') : image.resize('x800') if image[:width] > 800
    image.strip
    image.write main
  end

  def build_base_images
    # paths
    src  = path
    main = path :main

    build_watermarks
    build_main_image
    build_correct_preview

    # delete source
    image = MiniMagick::Image.open main
    image.write src

    # put copyright
    put_watermark_on_main_image

    # set process state
    src_size = File.size?(src)
    update(processing: :finished, attachment_file_size: src_size)
  end

  # IMAGE ROTATION
  def image_rotate angle
    src      = path
    main     = path :main
    preview  = path :preview

    # main
    image = MiniMagick::Image.open src
    image.rotate angle
    image.write src
    image.write main

    # preview
    image = MiniMagick::Image.open main
    image.resize "100x100!"
    image.write preview
  end

  def rotate_left
    image_rotate "-90"
  end

  def rotate_right
    image_rotate "90"
  end

  # IMAGE CROP
  def crop_image name = :cropped_image, x0 = 0, y0 = 0, w = 100, h = 100, img_w = nil
    src      = path
    main     = path :main
    cropped  = path name

    image = MiniMagick::Image.open main
    
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