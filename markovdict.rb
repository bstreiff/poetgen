class MarkovDict
   attr_reader :dict, :order

   def initialize(order, dictionary = nil)
      @wordSplitRegex = /(\.\s+)|(\.$)|([!?,;:])|--|[\s]+/
      @sentenceSplitRegex = /(?<=[.!?])\s+/
      @order = order

      if (dictionary.nil?)
         @dict = Hash.new
      else
         @dict = dictionary
      end
   end

   def add_file(filename)
      raise FileNotFoundError.new("#{filename} doesn't exist!") if !File.exists?(filename)

      self.add_sequences(split_preserving_prefixes(File.open(filename, "r").read))
   end

   def add_string(str)
      self.add_sequences(split_preserving_prefixes(str))
   end

   def split_preserving_prefixes(content)
      # the /(?<=[.!?])\s+/ regex is overeager in the cases of Mr., Ms., Mrs., St.
      # and I can't figure out how to make one that isn't... so do it the hard way
      content = content.gsub("Mr.", "Mr\u3002")
      content.gsub!("Mrs.", "Mrs\u3002")
      content.gsub!("Ms.", "Ms\u3002")
      content.gsub!("Dr.", "Ms\u3002")
      content.gsub!("St.", "St\u3002")
      
      content.split(@sentenceSplitRegex)
   end

   def add_atom_for_hash(hashValue, atom)
      probTable = @dict[hashValue]
      if (probTable.nil?) then
         probTable = Hash.new(0)
         @dict[hashValue] = probTable
      end
      probTable[atom] += 1
   end

   def add_sequence(atoms)
      state = [:startOfMessage] * @order
      atoms.reverse_each do |atom|
         next if (atom.length == 0)

         atom.gsub!("\u3002", ".")

         self.add_atom_for_hash(state.hash, atom)
         state.shift
         state.push(atom)
      end
      
      #self.add_atom_for_hash(state.hash, nil)
   end

   def add_sequences(sentences)
      sentences.each do |sentence|
         self.add_sequence(sentence.split(@wordSplitRegex))
      end
   end
end
