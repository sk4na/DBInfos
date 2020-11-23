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

end.parse!


############################################################################################
## MAIN
############################################################################################
Dir.chdir("/mnt/home/users/bio_267_uma/apareslar/projects/Db_documents/monarch_graph/tsv/all_associations/")
files = Dir.entries(Dir.pwd) - [".", ".."]
all_nodes = []
files.each do |filename|
	nodes_file = filename.split(".", 2)[0]
	array_nodes_file = nodes_file.split("_")
	all_nodes << array_nodes_file
end

g = GraphViz.new( :G, :type => :digraph )

## Adding the nodes that will form the graph ##
variant = g.add_nodes("variant")
genotype = g.add_nodes("genotype")
gene = g.add_nodes("gene")
function = g.add_nodes("function")
disease = g.add_nodes("disease")
chemical = g.add_nodes("chemical")
marker = g.add_nodes("marker")
interaction = g.add_nodes("interaction")
model = g.add_nodes("model")
publication = g.add_nodes("publication")
cases = g.add_nodes("cases")
homology = g.add_nodes("homology")
phenotype = g.add_nodes("phenotype")
pathway = g.add_nodes("pathway")

## Assigning the edges ##
all_nodes.each do |pair|
	g.add_edges(pair[0], pair[1])
end

## Saving the final graph ##
g.output(:png => "#{options[:output]}.png")	