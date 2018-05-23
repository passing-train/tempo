class GeneralUtility

  def self.interpret_add_key_val(row, keys, key, val)
    if(!keys.kind_of?(Array)||keys.include?(key))
      row[key] = val
    end
    row
  end
end
