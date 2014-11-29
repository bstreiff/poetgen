#!/usr/bin/env ruby
require "rubygems"
require_relative "pronounce"
require_relative "markovdict"
require_relative "markovgen"
require_relative "stanzagen"

# load dictionaries
Pronounce.import_dictionary("dictionary/cmudict.0.7a")

# make a new markov dictionary with order 2
markovDict = MarkovDict.new(2)

# seed it
markovDict.add_file("seeds/eisenhower_sotu.txt")
markovDict.add_file("seeds/the_adventures_of_sherlock_holmes.txt")
markovDict.add_file("seeds/pride_and_prejudice.txt")

# Aim for 9-15 syllables per line
markovGen = MarkovGenerator.new(markovDict, 9, 15)

# create stanzas with an ABAB rhyme scheme
stanzaGen = StanzaGenerator.new(markovGen, "ABAB")

# Twelve stanzas.
(0..11).each do |x|
   print stanzaGen.generate
end
