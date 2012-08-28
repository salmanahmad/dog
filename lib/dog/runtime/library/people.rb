#
# Copyright 2011 by Salman Ahmad (salman@salmanahmad.com).
# All rights reserved.
#
# Permission is granted for use, copying, modification, distribution,
# and distribution of modified versions of this work as long as the
# above copyright notice is included.
#

module Dog::Library
  module People
    include ::Dog::NativePackage

    name "people"

    collection "people" do
      type "people.person"
    end

    structure "public" do

    end

    structure "person" do
      property "id"
      property "first_name"
      property "last_name"
      property "handle"
      property "email"
      property "facebook"
      property "twitter"
      property "google"
      property "communities"
      property "profile"
    end
  end
end
