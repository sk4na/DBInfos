def load_profiles(file, col_disease_id, col_hpo_id)
  profiles = {}
  File.open(file).each do |line|
    fields = line.chomp.split("\t")
    disease_id = fields[col_disease_id]
    hpo_id = fields[col_hpo_id]    
    query = profiles[disease_id]
      if query.nil?
         profiles[disease_id] = [hpo_id]
      else
        query << hpo_id
      end
  end  
  return profiles
end

def prof_avg_size(profile)
  sizes_sorted = profile.map {|k,v| v.length}.sort
  average_size = sizes_sorted.inject{ |sum, el| sum + el }.to_f / sizes_sorted.length
  
  return average_size
end

def prof_percentile(profile, percentile)
    sizes_sorted = profile.map {|k,v| v.length}.sort
    k = (percentile*(sizes_sorted.length-1)+1).floor - 1
    f = (percentile*(sizes_sorted.length-1)+1).modulo(1)

    return sizes_sorted[k] + (f * (sizes_sorted[k+1] - sizes_sorted[k]))
end