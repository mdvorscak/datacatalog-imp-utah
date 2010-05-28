#! /usr/bin/ruby
require 'puller'
require 'source_puller'
class TestDriver

	if __FILE__==$0
		s=SourcePuller.new
		begin
			ret_val=s.fetch
			debugger
		end while !ret_val.nil?
	end
end
