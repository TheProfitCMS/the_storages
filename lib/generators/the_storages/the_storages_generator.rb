class TheStoragesGenerator < Rails::Generators::NamedBase
  source_root File.expand_path('../templates', __FILE__)
  # argument :xname, type: :string, default: :xname

  def generate_controllers
    if gen_name == 'install'
      cp_init_file
    else
      puts 'TheStorages Generator - wrong Name'
      puts 'Try to use [install]'
    end
  end

  private

  def gen_name
    name.to_s.downcase
  end

  def cp_init_file
    copy_file 'the_storages.rb', 'config/initializers/the_storages.rb'
  end
end
