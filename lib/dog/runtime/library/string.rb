module Dog::Library
  module String
    include ::Dog::NativePackage

		name "string"


		implementation "concat:on:with" do
			argument "string1"
			argument "string2"
			body do |track|
				string1 = variable("string1").value
				string2 = variable("string2").value
				newstring = ::Dog::Value.string_value(string1 << string2)
				dog_return(newstring)
			end
		end

		implementation "count:on:of" do
			argument "origstring"
			argument "string1"
			body do |track|
				origstring = variable("origstring").value
				string1 = variable("string1").value
				counted = origstring.count(string1)
				position = ::Dog::Value.number_value(counted)
				dog_return(position)
			end
		end

		implementation "delete:on:of" do
			argument "origstring"
			argument "string1"
			body do |track|
				origstring = variable("origstring").value
				string1 = variable("string1").value
				newstring = ::Dog::Value.string_value(origstring.delete(string1))
				dog_return(newstring)
			end
		end

		implementation "downcase:of" do
			argument "string"
			body do |track|
				string = variable("string").value
				newstring = ::Dog::Value.string_value(string.downcase)
				dog_return(newstring)
			end
		end

		implementation "index:on:of" do
			argument "string"
			argument "substring"
			body do |track|
				string = variable("string").value
				substr = variable("substring").value
				rawindex = string.index(substr)
				if rawindex == nil then
					index = ::Dog::Value.null_value
				else 
					index = ::Dog::Value.number_value(rawindex)
				end
				dog_return(index)
			end
		end

		implementation "insert:on:at:with" do
			argument "string"
			argument "index"
			argument "inserted"
			body do |track|
				string = variable("string").value
				index = variable("index").value
				inserted = variable("inserted").value
				newstring = ::Dog::Value.string_value(string.insert(index, inserted))
				dog_return(newstring)
			end
		end

		implementation "length:of" do
			argument "string"
			body do |track|
				string = variable("string").value
				length=::Dog::Value.number_value(string.length)
				dog_return(length)
			end
		end

		implementation "prepend:on:with" do
			argument "string1"
			argument "string2"
			body do |track|
				string1 = variable("string1").value
				string2 = variable("string2").value
				newstring = ::Dog::Value.string_value(string1.prepend(string2))
				dog_return(newstring)
			end
		end

		implementation "replace:on:swap:with" do
			argument "origstring"
			argument "findstring"
			argument "replacestring"
			body do |track|
				origstring = variable("origstring").value
				findstring = variable("findstring").value
				replacestring = variable("replacestring").value
				newstring = ::Dog::Value.string_value(origstring.sub(findstring, replacestring))
				dog_return(newstring)
			end
		end

		implementation "replaceall:on:swap:with" do
			argument "origstring"
			argument "findstring"
			argument "replacestring"
			body do |track|
				origstring = variable("origstring").value
				findstring = variable("findstring").value
				replacestring = variable("replacestring").value
				newstring = ::Dog::Value.string_value(origstring.gsub(findstring, replacestring))
				dog_return(newstring)
			end
		end

		implementation "reverse:of" do
			argument "string"
			body do |track|
				string = variable("string").value
				newstring = ::Dog::Value.string_value(string.reverse)
				dog_return(newstring)
			end
		end

		implementation "strip:on" do
			argument "string"
			body do |track|
				string = variable("string").value
				newstring = ::Dog::Value.string_value(string.strip)
				dog_return(newstring)
			end
		end

		implementation "substring:of:starting:until" do
			argument "string"
			argument "sindex"
			argument "eindex"
			body do |track|
				string = variable("string").value
				sindex = variable("sindex").value
				eindex = variable("eindex").value
				startint = Integer(sindex)
				endint = Integer(eindex)
				substring = string[startint..endint]
				substringv = ::Dog::Value.string_value(substring)
				dog_return(substringv)
			end
		end

		implementation "upcase:of" do
			argument "string"
			body do |track|
				string = variable("string").value
				newstring = ::Dog::Value.string_value(string.upcase)
				dog_return(newstring)
			end
		end

	end
end
