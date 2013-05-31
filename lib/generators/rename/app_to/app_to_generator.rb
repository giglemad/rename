module Rename
  module Generators
    class AppToGenerator < Rails::Generators::Base
      argument :new_name, :type => :string, :default => "#{Rails.application.class.parent}"

      def app_to
        mod_name = new_name.gsub(/[^0-9A-Za-z]/, ' ').split(' ').map { |w| w.capitalize }.join('')

        if mod_name.blank?
          puts "Error:Invalid name"
          return
        end

        new_module_name(mod_name)
        new_directory_name(new_name)
        replace_gemset_name_in_rvmrc(new_name)
      end

      private
      def new_module_name(new_name)
        search_exp = /(#{Regexp.escape("#{Rails.application.class.parent}")})/m

        in_root do
          #Search and replace in to root
          puts "Search and Replace Module in to..."
          Dir["*"].each do |file|
            replace_module_in_file(file, search_exp, new_name)
          end

          #Search and replace under config
          Dir["config/**/**/*.rb"].each do |file|
            replace_module_in_file(file, search_exp, new_name)
          end

          #Rename session key
          session_key_file = 'config/initializers/session_store.rb'
          search_exp = /((\'|\")_.*_session(\'|\"))/i
          session_key = "'_#{new_name.gsub(/[^0-9A-Za-z_]/, '_').downcase}_session'"
          replace_module_in_file(session_key_file, search_exp, session_key)
        end
      end

      def replace_module_in_file(file, search_exp, module_name)
        return if File.directory?(file)

        begin
          gsub_file file, search_exp do |m|
            module_name
          end
        rescue Exception => ex
          puts "Error:#{ex.message}"
        end
      end

      def new_directory_name(new_name)
        begin
          print "Renaming directory..."
          new_app_name = new_name.gsub(/[^0-9A-Za-z_]/, '-')
          new_path = Rails.root.to_s.split('/')[0...-1].push(new_app_name).join('/')
          File.rename(Rails.root.to_s, new_path)
          puts "Done!"
        rescue Exception => ex
          puts "Error:#{ex.message}"
        end
      end
      
      def replace_gemset_name_in_rvmrc(new_name)
        gsub_file '.rvmrc', /@(.*)\s/, new_name
      end
    end
  end
end
