#!/usr/bin/env ruby
require "rubygems"
require "pronounce/word"

# replacement for the pronounce gem's Pronounce module.
# I want to use some of its algorithms but the interface isn't nearly complete enough...
module Pronounce
   class << self
      def syllables(word)
         w = word.downcase
         if (is_word(w))
            dictionary[w].syllables.map &:to_strings
         else
            nil
         end
      end

      def add(word, phones)
         dictionary[word.downcase] = Word.new(phones)
      end

      def is_word(word)
         dictionary.has_key?(word.downcase)
      end

      def dictionary
         @dict ||= {}
      end

      def import_dictionary(file)
         File.readlines(file).each do |line|
            next if line.strip.empty? || line[0] == ";"
            word, *phones = line.strip.split
            dictionary[word.downcase] = Word.new(phones)
         end
      end

      def infer_word(word, recursive = false)
         if (!word.match(/[a-zA-Z]/))
            # if there are no characters in it, there's nothing to pronounce...
            return nil
         end

         # remove any surrounding quote characters
         word = word.match(/["',.:;]*([A-Za-z0-9]+([']?[A-Za-z0-9]+)?)["',.:;]*/)[1]

         if is_word(word)
            return syllables(word)
         end

         lowerword = word.downcase

         # Not in the database. Try to figure it out.
         # does it end with "'s", "s'", "es", or "s"?
         [/^(.*)'s$/, /^(.*)s'/, /^(.*)es$/, /^(.*)s$/].each do |suffixRegex|
            match = lowerword.match(suffixRegex)
            if (match)
               syls = infer_word(match[1], true)
               if (!syls.nil?)
                  add(word, syls.flatten! + ["Z"])
                  return syllables(word);
               end
            end
         end

         # does it start with "un"?
         [/^un(.*)$/].each do |prefixRegex|
            match = lowerword.match(prefixRegex)
            if (match)
               syls = infer_word(match[1], true)
               if (!syls.nil?)
                  add(word, ["AH0", "N"] + syls.flatten!)
                  return syllables(word);
               end
            end
         end

         # if there's a hyphen, split on the hyphen.
         if (word.index("-"))
            subwords = word.split("-")
            if (subwords.all?(&method(:is_word)))
               return subwords.collect_concat {|w| syllables(w)}
            end
         end

         # maybe it's a compound word. As a heuristic, let's say that no part
         # of the word may be less than three characters.
         if (word.length >= 6)
            (3..(word.length-3)).each do |firstWordLength|
               firstWord = word.slice(0, firstWordLength)
               secondWord = word.slice(firstWordLength, word.length)
               if (is_word(firstWord) && is_word(secondWord))
                  firstPronounce = syllables(firstWord).flatten;
                  secondPronounce = syllables(secondWord).flatten;
                  add(word, firstPronounce + secondPronounce);
                  return syllables(word)
               end
            end
         end

         # was the source word all capitalized? if so, maybe it's an acronym
         if (word == word.upcase && word.match(/^[A-Z]+$/))
            return word.each_char.collect do |c| syllables(c).flatten end
         end

         #puts "I don't know how to pronounce: #{word}" if !recursive
         return nil
      end

      def is_vowel(phoneme)
         return vowel_list.include?(phoneme)
      end

      def vowel_list
         @vowels ||= ["AA","AE","AH","AO","AW","AY","EH","ER","EY","IH","IY","OW","OY","UH","UW"]
      end

      def check_rhyme(firstWord, secondWord)
         first = infer_word(firstWord)
         return false if (first.nil?)
         second = infer_word(secondWord)
         return false if (second.nil?)

         first.flatten!.reverse!.map! { |x| x.gsub(/[012]/, "") }
         second.flatten!.reverse!.map! { |x| x.gsub(/[012]/, "") }

         minPhones = [first.length, second.length].min
         (0..minPhones).each do |index|
            break if (first[index] != second[index])

            return true if (is_vowel(first[index]) && is_vowel(second[index]))
         end

         return false
      end

   end
end
