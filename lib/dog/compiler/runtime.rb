
class Track
  attr_accessor :current_instruction
  attr_accessor :next_instruction
  attr_accessor :context
  attr_accessor :stack
  attr_accessor :variables
  
  def initialize
    self.current_instruction = 0
    self.next_instruction = nil
    self.context = nil
    self.stack = []
    self.variables = {}
  end
end


class Runtime
  class << self
    def run(package)
      
      track = Track.new
      track.context = package.symbols["@root"]
      instructions = track.context["instructions"]
      
      puts "--------"
      
      loop do
        instruction = instructions[track.current_instruction]
        break unless instruction
        
        instruction.execute(track)
        
        if track.next_instruction then
          track.current_instruction = track.next_instruction
        else
          track.current_instruction += 1
        end
      
        track.next_instruction = nil
      end
      
      puts "--------"
      puts
      
      puts track.stack.inspect
      
    end
  end
end