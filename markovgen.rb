def weighted_sample(list)
   return nil if (list.length == 0)

   sum = list.values.inject(:+)

   accumulator = 0;
   cumList = {}
   list.each { |obj, weight| cumList[obj] = (accumulator+=weight) }
   r = rand() * sum
   result = cumList.find { |obj, weight| weight > r }

   if (result.nil?)
      return nil
   else
      return result[0]
   end
end

class MarkovGenerator
   attr_reader :softCap, :hardCap

   def initialize(markovDict, softCap = nil, hardCap = nil)
      softCap = 50 if softCap.nil?
      hardCap = softCap * 2 if hardCap.nil?

      @markovDict = markovDict
      @softCap = softCap
      @hardCap = hardCap
   end

   # instead of a proper depth-first-search, lets just pop the stack
   # a random number of times and hope we go down a different path!
   def pop_random(stack)
      count = (rand() * (stack.length - 1)).to_i
      (1..count).each do stack.pop end
   end

   def generate(rhymesWith=nil)
      stack = []
      initialState = [:startOfMessage] * (@markovDict.order)

      stack.push({
         :state => initialState,
         :hasPerformedRhymeAction => false,
         :sylCount => 0,
         :result => []})

      restartCount = 0
      iteration = 0

      loop do
         iteration += 1
         if (iteration > (@softCap*15))
            # okay, we've spent waaaay too long going down whatever rabbit-hole
            # we're in... start over.
            stack = []
            stack.push({
               :state => initialState,
               :hasPerformedRhymeAction => false,
               :sylCount => 0,
               :result => []})
            iteration = 0
            restartCount += 1
         end
         if (restartCount > 3)
            raise "I tried real hard! But nothing worked. :("
         end

         if (stack.empty?)
            raise "popped more than I should have, ooops"
         end

         newState = stack[-1][:state].dup
         newHasPerformedRhymeAction = stack[-1][:hasPerformedRhymeAction]
         newSylCount = stack[-1][:sylCount]
         newResult = stack[-1][:result].dup
         lastOne = false

         probTable = @markovDict.dict[newState.hash]
         if (probTable.nil?)
            pop_random(stack)
            next
         end

         if (rhymesWith.nil? && !newHasPerformedRhymeAction)
            #print "selecting all pronouncable words\n"
            # first element must be something we know how to pronounce
            potentialPicks = probTable.select { |k,v| !k.nil? && Pronounce.is_word(k) }
            if (potentialPicks.empty?)
               # Nothing is rhymable. This may be the initial punctuation.
               newHasPerformedRhymeAction = false;
            else
               # Cool, we have pronouncable words.
               probTable = potentialPicks;
               newHasPerformedRhymeAction = true;
            end
         elsif (!rhymesWith.nil? && !newHasPerformedRhymeAction)
            # first element needs to rhyme with rhymesWith
            potentialPicks = probTable.select { |k,v| !k.nil? && k.downcase != rhymesWith.downcase && Pronounce.check_rhyme(k, rhymesWith) }
            if (potentialPicks.empty?)
               # Nothing is rhymable. Possible initial punctuation.
               newHasPerformedRhymeAction = false;
            else
               # Cool, we have pronouncable words.
               probTable = potentialPicks;
               newHasPerformedRhymeAction = true;
            end
         else # hasPerformedRhymeAction == true
            if (newSylCount > @softCap)
               # try to find a stopping point once we go past the soft cap
               # since we're walking in reverse, a 'stopping point' is a word with
               # a capital letter in it (which we assume is the first letter)
               maybeProbTable = probTable.select { |k,v| !k.nil? && !k.match(/[A-Z]/).nil?}
               if (!maybeProbTable.empty?)
                  probTable = maybeProbTable
                  lastOne = true
               end
            end
            if (newSylCount > @hardCap)
               pop_random(stack)
               next
            end
         end

         if (probTable.empty?)
            # No possibilities. We have to backtrack.
            pop_random(stack)
            next
         end

         nextAtom = weighted_sample(probTable)

         syls = Pronounce.infer_word(nextAtom)
         if (!syls.nil?)
            newSylCount += syls.length
         end

         newResult.push(nextAtom)
         newState.shift
         newState.push(nextAtom)

         if lastOne
            return newResult.reverse.compact
         else
            stack.push({
               :state => newState,
               :hasPerformedRhymeAction => newHasPerformedRhymeAction,
               :sylCount => newSylCount,
               :result => newResult})
         end
      end
   end

end
