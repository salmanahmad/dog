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