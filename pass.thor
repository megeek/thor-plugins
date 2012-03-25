require 'thor'

class GenPass < Thor
  namespace :gen

  desc 'pass SIZE', 'Create a password with SIZE characters, defaults to 8'
  def pass(size = 8)
    size = Integer(size)
    srand

    upcase = (65..90)
    downcase = (97..122)
    numeric = (48..57)

    # No easy way to concatenate ranges AFAICT
    # In reality, we just need something Enumerable
    desired_range = upcase.to_a + downcase.to_a + numeric.to_a

    pass = ""
    while pass.size < size
      val = rand(127 - 32) + 32 # Remove the range of control characters

      pass << val.chr if desired_range.include? val.ord
    end

    puts pass
  end

  desc 'phrase SIZE', 'Create a passphrase with SIZE words, defaults to 5'
  def phrase(size = 5)
    size = Integer(size)
    srand

    lines = File.readlines('/usr/share/dict/words')

    phrase = []
    size.times do
      lineno = rand(lines.length)
      phrase << lines[lineno].chomp
    end
    puts phrase.join ' '
  end
end
