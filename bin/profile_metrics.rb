#! /usr/bin/env ruby

require 'optparse'
require '../lib/dbtools'
require '../lib/profiletools'

############################################################################################
## METHODS
############################################################################################


############################################################################################
## OPTPARSE
############################################################################################
options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: #{File.basename(__FILE__)} [options]"

  options[:profile_files] = nil
  opts.on("-p", "--profile_files file1, file2", Array, "String comma separated with paths to profile files") do |item|
    options[:profile_files] = item
  end
  	
end.parse!


############################################################################################
## MAIN
############################################################################################
profile_1 = load_profiles(options[:profile_files].first)
profile_2 = load_profiles(options[:profile_files].last)

avg_size_1 = prof_avg_size(profile_1)
avg_size_2 = prof_avg_size(profile_2)

percentile_1 = prof_percentile(profile_1, 0.90)
percentile_2 = prof_percentile(profile_2, 0.90)

puts "#{options[:profile_files].first}\t#{avg_size_1}\t#{percentile_1}"
puts "#{options[:profile_files].last}\t#{avg_size_2}\t#{percentile_2}"