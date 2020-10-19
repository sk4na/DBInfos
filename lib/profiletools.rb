def load_profiles(file)
  profiles = {}
  File.open(file).each do |line|
    fields = line.chomp.split("\t")
    disease_id = fields.first
    hpo_id = fields.last.split(',')
  end  
  return profiles
end

def prof_avg_size(profiles)
  sizes = profiles.map {|k,v| v.length}
  average_size = sizes.inject{ |sum, el| sum + el }.to_f / sizes.length
  return average_size
end

def prof_percentile(profiles, percentile)
    sizes_sorted = profiles.map {|k,v| v.length}.sort
    percentile_index = percentile*(sizes_sorted.length-1)
    k = percentile_index.floor
    return sizes_sorted[k]
end