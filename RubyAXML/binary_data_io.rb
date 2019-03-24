module BinaryDataIO
  class CheckError < IOError; end

  def readByte; io.read(1).unpack('c'); end
  def readUByte; io.getbyte; end

  def readNByteInt(n, reader = 'readUByte')
    result, i = [0, 0]
    while i < n
      byte = send(reader)

      raise EOFError, "Scanning #{state}: unexpected EOF, expecting (total/rest) (#{n}/#{n-i}) bytes" if byte == nil

      result |= byte << (8*i)
      i += 1
    end

    return result
  end

  def readShort; io.read(2).unpack('s'); end
  def readUShort; readNByteInt(2); end

  def readInt; io.read(4).unpack('l'); end
  def readUInt; readNByteInt(4); end

  def skipN(n); io.seek(n); end

  def expecting(byte)
    result = ''
    result << b = readByte
    while b != byte
      result << b = readByte
    end
    return result
  end

  def readNULString
    expecting("\0").unpack("Z")
  end

  def readAndCheckEq(expect, reader = 'readUByte')
    got = send(reader)

    if got != expect
      raise CheckError, "Scanning #{state}: Found #{got} while expecting #{expect}"
    end
  end

  def bulkRead(times, reader = 'readUInt')
    result = ''
    while times > 0
      result << send(reader)
    end
    return result
  end

  def readCast(reader = 'readUInt', caster = proc{|x|x})
    got = send(reader)
    return caster.call(got)
  end
end
