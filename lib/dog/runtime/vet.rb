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
      def self.initialize_vet
        return if @initialize_vet
        @initialize_vet = true
        
        prefix = Config.get('dog_prefix')
        
        get_or_post prefix + 'vet' do
          body "Dog Meta Data."
        end
      end
    end
  end
  
end