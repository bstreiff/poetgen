An entry for NaNoGenMo 2014. See https://github.com/dariusk/NaNoGenMo-2014

This is a (rather primitive) markov-chain-based poetry generator. It is
seeded with the following sources, all on Project Gutenburg:
- Pride and Prejudice (https://www.gutenberg.org/ebooks/1342)
- The Adventures of Sherlock Holmes (https://www.gutenberg.org/ebooks/1661)
- Eisenhower's State of the Union addresses (https://www.gutenberg.org/ebooks/5040)

Some manual processing has taken place to remove the "front matter" from
the PG text files.

Sample output: https://gist.github.com/bstreiff/b95f352c488a76355cce

It requires the git version of the "pronounce" gem: https://github.com/josephwilk/pronounce

I actually substitute my own interface on top of some of the lower-level
algorithms provided by the gem (mostly the syllabification). I also have
some code in place to try to make the word lookups a bit more robust
(for instance, by breaking down words like "recently-used") than what
is provided in the CMU Pronouncing Dictionary.

In its default configuration it doesn't generate "50,000 words" as noted
as the NaNoGenMo "goal" but could do so with only minor changes.

This was implemented in Ruby mostly for the rapid-prototyping aspect (also
the presence of "pronounce" helped). I make no claims that this should be
considered in any way to be high-quality Ruby code.