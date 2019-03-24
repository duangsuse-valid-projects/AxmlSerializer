# BinaryDataReader default readers
module BinaryDataReader
  ## Read N Bytes to Integer
  def readNByteInt(n, reader = U8)
    result, i = [0, 0]
    while i < n
      byte = readerRead(reader)

      result |= byte << (8*i)
      i += 1
    end

    return result
  end

  ## read all bytes until ...
  def readUntil(reader = U8)
    raise 'Shuold give a predicate block' unless block_given?
    result = StringIO.new

    result << b = readerRead(reader)

    while yield b
      result << b = readerRead(reader)
    end

    return result
  end

  ## read all bytes until byte found
  def readUntilByte(byte)
    result = StringIO.new
    result << b = readU8
    while b != byte
      result << b = readU8
    end
    return result
  end

  def readCStr
    readUntilByte("\0").unpack("Z")
  end

  def readCWStr
    readUntilByte("\0").encode
  end

  def readXPrefixStr(prefix_reader = U16)
    len = readerRead(prefix_reader)
    bytes = readNBytes(len)
    bytes.string.reverse
  end

  def readXPrefixWStr(prefix_reader = U16)
    len = readerRead(prefix_reader)
    bytes = readNBytes(len)
    bytes.string.reverse
  end
end

# readNX (bulk reading)
# skipX
# checkX
# checkXEq
# readXTo (read and cast)
module BinaryDataReader
  def readN_X_(x = U8, n = 2)
    result = StringIO.new
    while n > 0
      result << readerRead(x)
      n -= 1
    end
    return result
  end

  def skip_X_(x = U8)
    skip(x[1..-1].to_i)
  end

  def skipN_X_(x = U8, n = 2)
    while n < 0
      skipX(x)
      n -= 1
    end
  end

  def check_X_(x = U8, &checker)
    got = readerRead(x)
    unless message = checker.call(got)
      raise CheckError, "Scanning #{state}: Found #{got} while expecting #{expect}#{message}"
    end
  end

  def check_X_Eq(x = U8, expected)
    got = readerRead(x)
    unless got == expected
      raise CheckError, "Scanning #{state}: Found #{got} while expecting #{expect}"
    end
  end

  def read_X_To(x = U8, transfrom = ->(x){x})
    got = readerRead(x)
    return transfrom.call(got)
  end

  # define curry functions
  def make_quickaccess(instance)
    instance_methods.each do |m|
      all = m.match(/(\S+)_X_(\S+)/)
      before, after = all.captures unless all.nil?

      %w[8 16 32 64].each do |digi|
        for sign in ['I', 'U']
          new_name = "#{before}#{sign}#{digi}#{after}"
          colsure = instance_method(m).bind(instance).curry.call("#{sign}#{digi}")
          define_method(new_name, &closure)
        end
      end
    end
  end
end
