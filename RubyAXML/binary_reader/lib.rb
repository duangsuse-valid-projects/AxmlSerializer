## Binary Data Reader module
## Based on Ruby's IO class and unpack function

require './delegates'
require './read'

# => Operations

# skipNBytes(n)
# readNBytes(n)

# readU8 / readI8
# readU16 / readI16
# readU32 / readI32
# readU64 / readI64

# readNByteInt(n)
# readUntil(&p)
# readUntilByte(byte)

# readCStr / readXPrefixStr
# readCWStr / readXPrefixWStr


# readNX
# skipX
# checkX
# checkXEq
# readXTo
module BinaryDataReader
  BITS_BYTE = 8

  ## Byte-size of n-bits integral type
  def self.bytesize_of(n); n / BITS_BYTE; end

  SIZE_8 = bytesize_of(8)
  SIZE_16 = bytesize_of(16)
  SIZE_32 = bytesize_of(32)
  SIZE_64 = bytesize_of(64)

  attr_accessor :pos_stack

  def mark; pos_stack << tell; end
  def reset; seek(pos_stack.pop); end

  # Run reader
  def readerRead(reader_name); send(reader_name); end

  ## Binary validation error
  class CheckError < Exception; end

  ## Skip N Bytes
  def skipNBytes(n); io.skip(n); end

  ## Read N Bytes
  def readNBytes(n)
    result = StringIO.new
    while n > 0
      result << readU8
    end
  end

  def readAndUnpack(size, fmt)
    begin
      return io.read(size).unpack(fmt)
    rescue EOFError => e
      raise EOFError, "Scanning #{state}: unexpected EOF, expecting #{size} bytes"
    end
  end

  ## Read a signed char
  def readI8; io.read(SIZE_8).unpack('c'); end
  ## Read an unsigned char
  def readU8; io.getbyte; end

  ## Read a signed short
  def readI16; io.read(SIZE_16).unpack('s'); end
  ## Read an unsigned short
  def readU16; io.read(SIZE_16).unpack('S'); end

  ## Read a signed int
  def readI32; io.read(SIZE_32).unpack('l'); end
  ## Read an unsigned int
  def readU32; io.read(SIZE_32).unpack('L'); end

  ## Read a signed long
  def readI64; io.read(SIZE_64).unpack('q'); end
  ## Read an unsigned long
  def readU64; io.read(SIZE_64).unpack('Q'); end

  # Add aliases for reader name
  instance_methods.each do |met|
    all_match = met.match(/read(U|I)(\d+)/)
    type, len = all_match.captures unless all_match.nil?
    const_set("#{type.capitalize}#{len}", all_match.to_s) if type
  end
end
