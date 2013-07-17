module WatermarkFu
  extend ActiveSupport::Concern

  def has_watermark?
    TheStorages.has_watermark?
  end

  def watermark_dir_path
    dir_path  = TheStorages.config.watermarks_path
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
    path = TheStorages.config.watermark_font_path
    File.exists?(path.to_s) ? path : 'Times-Roman'
  end

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
    
    text     = TheStorages.config.watermark_text
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

  def put_watermark_on_base_image
    base  = path :base
    image = MiniMagick::Image.open base

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

    Cocaine::CommandLine.new("composite", " #{stick} #{shift} #{opacity} #{watermark} #{base} #{base}").run
    base
  end
end