#
# Copyright 2011 by Salman Ahmad (salman@salmanahmad.com).
# All rights reserved.
#
# Permission is granted for use, copying, modification, distribution,
# and distribution of modified versions of this work as long as the
# above copyright notice is included.
#

module Dog
  class Signal
    attr_accessor :call_track
    attr_accessor :schedule_track
    attr_accessor :pause
    attr_accessor :stop
    attr_accessor :exit
  end
end