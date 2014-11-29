class StanzaGenerator
   def initialize(markovGenerator, rhymeScheme = "ABAB")
      @markovGen = markovGenerator
      @rhymeScheme = rhymeScheme
   end

   # like .join(" ") but handles punctuation better
   def join_atoms(ary)
      out = ""
      ary.each do |a|
         out += " " if (out.length != 0 && !a.match(/^[,:;.?!]+$/))
         out += a
      end
      return out
   end

   # Get the last atom in the list that isn't all punctuation.
   def get_rhymable_word(atoms)
      atoms.reverse_each do |atom|
         if (!atom.match(/^[,:;.?!]+$/))
            return atom
         end
      end
   end

   def generate()
      firstLine = secondLine = thirdLine = fourthLine = []

      loop do
         begin
            if (@rhymeScheme == "ABAB")
               firstLine = @markovGen.generate()
               secondLine = @markovGen.generate()
               thirdLine = @markovGen.generate(get_rhymable_word(firstLine))
               fourthLine = @markovGen.generate(get_rhymable_word(secondLine))
            elsif (@rhymeScheme == "ABBA")
               firstLine = @markovGen.generate()
               secondLine = @markovGen.generate()
               thirdLine = @markovGen.generate(get_rhymable_word(secondLine))
               fourthLine = @markovGen.generate(get_rhymable_word(firstLine))
            elsif (@rhymeScheme == "ABCB")
               firstLine = @markovGen.generate()
               secondLine = @markovGen.generate()
               thirdLine = @markovGen.generate()
               fourthLine = @markovGen.generate(get_rhymable_word(secondLine))
            else
               raise "Unknown rhyme scheme."
            end

            break # success! stop retrying.
         rescue
            # Whoops, couldn't generate a stanza. We'll try again!
            # Isn't randomness fun?
         end
      end

      out  = join_atoms(firstLine)
      out += "\n"
      out += join_atoms(secondLine)
      out += "\n"
      out += join_atoms(thirdLine)
      out += "\n"
      out += join_atoms(fourthLine)
      out += "\n\n"
      return out;
   end

end
