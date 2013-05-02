class ChangeStorages < ActiveRecord::Migration
  def change
    change_table :users do |t|
      t.integer :all_attached_files_count, default: 0
      t.integer :all_attached_files_size,  default: 0
    end

    # [:users, :pages, :posts, :articles, :recipes, :blogs, :notes, :hubs].each do |table_name|
    #   change_table table_name do |t|
    #     t.integer :storage_files_count, default: 0
    #     t.integer :storage_files_size,  default: 0
    #   end
    # end
  end
end
