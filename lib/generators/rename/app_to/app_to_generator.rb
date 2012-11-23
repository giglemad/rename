module Rename
  module Generators
    class AppToGenerator < Rails::Generators::Base
      argument :new_name, :type => :string, :default => "#{Rails.application.class.parent}"

      def app_to
        mod_name = new_name.gsub(/[^0-9A-Za-z]/, ' ').split(' ').map {|w| w.capitalize}.join('')

        if mod_name.blank?
          puts "Error:Invalid name"
          return
        end

        new_module_name(mod_name)
        new_directory_name(new_name)
      end

      private
      def new_module_name(new_name)
        search_exp = /(#{Regexp.escape("#{Rails.application.class.parent}::")})/mi

        in_root do
          #Search and replace in to root
          puts "Renaming in root..."
          Dir["*"].each do |file|
            replace_module_in_file(file, search_exp, new_name)
          end

          #Search and replace under config
          puts "Renaming configuration..."
          Dir["config/**/**/*.rb"].each do |file|
            replace_module_in_file(file, search_exp, new_name)
          end
        end
      end

      def replace_module_in_file(file, search_exp, module_name)
        return if File.directory?(file)
        gsub_file file, search_exp do |m|
          "#{module_name}::"
        end
      end

      def new_directory_name(new_name)
        new_dir_name = new_name.gsub(/[^0-9A-Za-z\-_]/, '-')
        puts "Renaming directory..."
        File.rename "#{Rails.root}", "#{new_dir_name}"
      end
    end
  end
end