module Error
  module ErrorSerializer

    def ErrorSerializer.serialize(object)
      return if object.errors.empty?

      new_hash = object.errors.to_hash.map do |k, v|
        v.map do |msg|
          { field: k, message: msg }
        end
      end.flatten
      return new_hash
    end

  end
end