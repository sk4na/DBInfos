def load_obo(file, keyword)
  records = {}
  mondo_code = nil
  keyword_related = []
  File.open(file).each do |line|
    line.chomp!
    tag, value = line.split(": ", 2)
    if tag == "[Term]"
        if !mondo_code.nil?
          if keyword_related.length == 0
            keyword_related = []
          end  
          records[mondo_code] = keyword_related
        end
        keyword_related = []
        mondo_code = nil
    elsif tag == 'id'
      mondo_code = value
    elsif tag == 'xref'
      xcode, xmetadata = value.split(' ')
      if xcode.include?(keyword)
        keyword_related << xcode
      end
    end
  end
  if keyword_related.length == 0
    keyword_related = []
  end
  records[mondo_code] = keyword_related ## Esta linea hace falta para guardar el caso final  
  return records
end

def load_file(file)
  records = []
  File.open(file).each do |line|
    line.chomp!
    fields = line.split("\t")
    records << fields 
  end
 return records
end

def load_tabular_file(file)
  records = []
  File.open(file).each do |line|
    line.chomp!
    fields = line.split("\t")
    records << fields 
  end
 return records
end

def load_id_file(file)
  records = []
  File.open(file).each do |line|
    records << line.chomp
  end
 return records
end

def get_ids(relations)
  ids = []
  relations.each do |relation|
    ids << relation[0]
  end
  ids = ids.uniq
  return ids  
end  

def load_profiles(file, col_disease_id, col_hpo_id, keyword)
  profiles = {}
  File.open(file).each do |line|
    fields = line.chomp.split("\t")
    if fields[col_disease_id].match(/#{keyword}/)
        disease_id = fields[col_disease_id]
        hpo_id = fields[col_hpo_id]    
        query = profiles[disease_id]
        if query.nil?
          profiles[disease_id] = [hpo_id]
        else
          query << hpo_id
        end
    end
  end  
  return profiles
end