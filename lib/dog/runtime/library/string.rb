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
				newstring = ::Dog::Value.string_value(string1.concat(string2))
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

		implementation "substringk:of:from:to" do
		#TODO fix this
			argument "string"
			argument "sindex"
			argument "eindex"
			body do |track|
				string = variable("string").value
				sindex = variable("sindex").value
				eindex = variable("eindex").value
				#startint = Integer(starting)
				#endint = Integer(ending)
				sreturn = ::Dog::Value.string_value(string)
				dog_return(sreturn)
				#printf startint, ", ", endint
				#substring = string[startint..endint]
				#substringf = ::Dog::Value.string_value(st)
				#dog_return(substringf)
			end
		end

	end
end
