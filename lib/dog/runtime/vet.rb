#
# Copyright 2011 by Rizwan Ahmad (rizwanahmad93@gmail.com).
# All rights reserved.
#
# Permission is granted for use, copying, modification, distribution,
# and distribution of modified versions of this work as long as the
# above copyright notice is included.
#

module Dog

  class Server < Sinatra::Base
    class << self
      def initialize_vet
        return if @initialize_vet
        @initialize_vet = true

        prefix = Config.get('dog_prefix')
        prefix += "/vet"

        Dir.foreach(File.join(File.dirname(__FILE__), "vet")) do |f|
          full_path = File.join(File.dirname(__FILE__), "vet", f)
          unless [".", ".."].include? f then
            route = prefix + "/" + f
            get route do
              send_file full_path
            end
          end
        end
      end
    end
  end
end