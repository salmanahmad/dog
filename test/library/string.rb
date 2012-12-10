#
# Copyright 2011 by Salman Ahmad (salman@salmanahmad.com).
# All rights reserved.
#
# Permission is granted for use, copying, modification, distribution,
# and distribution of modified versions of this work as long as the
# above copyright notice is included.
#

require File.expand_path(File.join(File.dirname(__FILE__), '..', 'test_helper.rb'))

class LibraryTests::StringTest < Test::Unit::TestCase
  include RuntimeHelper

	def test_concat
    program = <<-EOD

		string1 = "abcd1"
		string2 = "fgh"
		result1 = COMPUTE string.concat ON string1 WITH string2
		result2 = COMPUTE string.concat ON string2 WITH string1

    EOD

    tracks = run_source(program)
    track = tracks.last
		assert_equal(track.variables["result1"].ruby_value, "abcd1fgh")
		assert_equal(track.variables["result2"].ruby_value, "fghabcd1fgh")
	
	end

	def test_count
    program = <<-EOD

		string1 = "abc1"
		string2 = "jjkll"
		string3 = ""
		result1 = COMPUTE string.count ON string1 OF "a"
		result2 = COMPUTE string.count ON string1 OF "ab"
		result3 = COMPUTE string.count ON string1 OF "ac"
		result4 = COMPUTE string.count ON string2 OF "j"
		result5 = COMPUTE string.count ON string2 OF "jkl"
		result6 = COMPUTE string.count ON string3 OF "a"
		result7 = COMPUTE string.count ON string2 OF " "

    EOD

    tracks = run_source(program)
    track = tracks.last
		assert_equal(track.variables["result1"].ruby_value, 1)
		assert_equal(track.variables["result2"].ruby_value, 2)
		assert_equal(track.variables["result3"].ruby_value, 2)
		assert_equal(track.variables["result4"].ruby_value, 2)
		assert_equal(track.variables["result5"].ruby_value, 5)
		assert_equal(track.variables["result6"].ruby_value, 0)
		assert_equal(track.variables["result7"].ruby_value, 0)
	
	end

	def test_delete
    program = <<-EOD

		string1 = "abcd1"
		result1 = COMPUTE string.delete ON string1 OF "ab"
		result2 = COMPUTE string.delete ON string1 OF "abcd1"

    EOD

    tracks = run_source(program)
    track = tracks.last
		assert_equal(track.variables["result1"].ruby_value, "cd1")
		assert_equal(track.variables["result2"].ruby_value, "")
	
	end


	def test_downcase
    program = <<-EOD

		string1 = "ABCD1"
		string2 = "aBcD1"
		result1 = COMPUTE string.downcase OF string1
		result2 = COMPUTE string.downcase OF string2

    EOD

    tracks = run_source(program)
    track = tracks.last
		assert_equal(track.variables["result1"].ruby_value, "abcd1")
		assert_equal(track.variables["result2"].ruby_value, "abcd1")
	
	end


	def test_index
    program = <<-EOD

		string1 = "abcb1"
		result1 = COMPUTE string.index ON string1 OF "b"
		result2 = COMPUTE string.index ON string1 OF "c"
		result3 = COMPUTE string.index ON string1 OF "x"

    EOD

    tracks = run_source(program)
    track = tracks.last
		assert_equal(track.variables["result1"].ruby_value, 1)
		assert_equal(track.variables["result2"].ruby_value, 2)
		assert_equal(track.variables["result3"].ruby_value, nil)
	
	end


	def test_insert
    program = <<-EOD

		string1 = "abcd1"
		string2 = ""
		result1 = COMPUTE string.insert ON string1 AT 1 WITH "k"
		result2 = COMPUTE string.insert ON string2 AT 0 WITH " "

    EOD

    tracks = run_source(program)
    track = tracks.last
		assert_equal(track.variables["result1"].ruby_value, "akbcd1")
		assert_equal(track.variables["result2"].ruby_value, " ")
	
	end


	def test_length
    program = <<-EOD

		string1 = "abcd1"
		string2 = "ab cd1"
		string3 = ""
		string4 = "  "
		result1 = COMPUTE string.length OF string1
		result2 = COMPUTE string.length OF string2
		result3 = COMPUTE string.length OF string3
		result4 = COMPUTE string.length OF string4

    EOD

    tracks = run_source(program)
    track = tracks.last
		assert_equal(track.variables["result1"].ruby_value, 5)
		assert_equal(track.variables["result2"].ruby_value, 6)
		assert_equal(track.variables["result3"].ruby_value, 0)
		assert_equal(track.variables["result4"].ruby_value, 2)
	
	end

	def test_prepend
    program = <<-EOD

		string1 = "abcd1"
		string2 = "fgh"
		result1 = COMPUTE string.prepend ON string1 WITH string2
		result2 = COMPUTE string.prepend ON string2 WITH string1

    EOD

    tracks = run_source(program)
    track = tracks.last
		assert_equal(track.variables["result1"].ruby_value, "fghabcd1")
		assert_equal(track.variables["result2"].ruby_value, "fghabcd1fgh")
	
	end

	def test_replace
    program = <<-EOD

		string1 = "abcDc1"
		result1 = COMPUTE string.replace ON string1 SWAP "a" WITH "f"
		result2 = COMPUTE string.replace ON string1 SWAP "b" WITH "ghi"
		result3 = COMPUTE string.replace ON string1 SWAP "c" WITH "j"
		result4 = COMPUTE string.replace ON string1 SWAP "d" WITH "k"

    EOD

    tracks = run_source(program)
    track = tracks.last
		assert_equal(track.variables["result1"].ruby_value, "fbcDc1")
		assert_equal(track.variables["result2"].ruby_value, "aghicDc1")
		assert_equal(track.variables["result3"].ruby_value, "abjDc1")
		assert_equal(track.variables["result4"].ruby_value, "abcDc1")
	
	end

	def test_replaceall
    program = <<-EOD

		string1 = "abcDc1"
		result1 = COMPUTE string.replaceall ON string1 SWAP "a" WITH "f"
		result2 = COMPUTE string.replaceall ON string1 SWAP "b" WITH "ghi"
		result3 = COMPUTE string.replaceall ON string1 SWAP "c" WITH "j"
		result4 = COMPUTE string.replaceall ON string1 SWAP "d" WITH "k"

    EOD

    tracks = run_source(program)
    track = tracks.last
		assert_equal(track.variables["result1"].ruby_value, "fbcDc1")
		assert_equal(track.variables["result2"].ruby_value, "aghicDc1")
		assert_equal(track.variables["result3"].ruby_value, "abjDj1")
		assert_equal(track.variables["result4"].ruby_value, "abcDc1")
	
	end

	def test_reverse
    program = <<-EOD

		string1 = "abcd1"
		string2 = " a"
		result1 = COMPUTE string.reverse OF string1
		result2 = COMPUTE string.reverse OF string2

    EOD

    tracks = run_source(program)
    track = tracks.last
		assert_equal(track.variables["result1"].ruby_value, "1dcba")
		assert_equal(track.variables["result2"].ruby_value, "a ")
	
	end

	def test_strip
    program = <<-EOD

		string1 = " abcd1"
		string2 = "abcd1 "
		string3 = "  abcd1  "
		string4 = "  a b c  "
		result1 = COMPUTE string.strip ON string1
		result2 = COMPUTE string.strip ON string2
		result3 = COMPUTE string.strip ON string3
		result4 = COMPUTE string.strip ON string4

    EOD

    tracks = run_source(program)
    track = tracks.last
		assert_equal(track.variables["result1"].ruby_value, "abcd1")
		assert_equal(track.variables["result2"].ruby_value, "abcd1")
		assert_equal(track.variables["result3"].ruby_value, "abcd1")
		assert_equal(track.variables["result4"].ruby_value, "a b c")
	
	end

	def test_substring
    program = <<-EOD

		string1 = "abcd1"
		result1 = COMPUTE string.substring OF string1 STARTING 1 UNTIL 3
		result2 = COMPUTE string.substring OF string1 STARTING 0 UNTIL 4

    EOD

    tracks = run_source(program)
    track = tracks.last
		assert_equal(track.variables["result1"].ruby_value, "bcd")
		assert_equal(track.variables["result2"].ruby_value, "abcd1")
	
	end

	def test_upcase
    program = <<-EOD

		string1 = "abcd1"
		string2 = "aBcD1"
		result1 = COMPUTE string.upcase OF string1
		result2 = COMPUTE string.upcase OF string2

    EOD

    tracks = run_source(program)
    track = tracks.last
		assert_equal(track.variables["result1"].ruby_value, "ABCD1")
		assert_equal(track.variables["result2"].ruby_value, "ABCD1")
	
	end



end
