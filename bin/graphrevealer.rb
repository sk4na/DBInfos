#! /usr/bin/env ruby

require 'optparse'
require 'ruby-graphviz'

############################################################################################
## OPTPARSE
############################################################################################
options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: #{File.basename(__FILE__)} [options]"

  options[:output] = nil
  opts.on("-o", "--output STRING", "Name of the outputted graph") do |item|
    options[:output] = item
  end

  options[:input_folder] = nil
  opts.on("-i", "--input_folder PATH", "Path to folder with Monarch data") do |item|
    options[:input_folder] = item
  end

end.parse!


############################################################################################
## MAIN
############################################################################################
files = Dir.glob(File.join(options[:input_folder], '*.all.tsv.gz'))
all_nodes = []
files.each do |file_path|
	filename = File.basename(file_path, '.all.tsv.gz')
	array_nodes_file = filename.split("_")
	all_nodes << array_nodes_file
end

g = GraphViz.new( :G, :type => :digraph )

## Assigning the edges ##
included_nodes = []
all_nodes.each do |nodeA, nodeB|
	if !included_nodes.include?(nodeA)
		included_nodes << nodeA
		g.add_nodes(nodeA)
	end
	if !included_nodes.include?(nodeB)
		included_nodes << nodeB
		g.add_nodes(nodeB)
	end
	g.add_edges(nodeA, nodeB)
end

## Saving the final graph ##
g.output(:png => "#{options[:output]}.png")	