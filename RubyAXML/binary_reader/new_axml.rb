#!env -S ruby -W2 -w -E UTF-8 -T0

require './lib'
require 'pp'

module AxmlResChunkTypes
  RES_NULL_TYPE               = 0x0000
  RES_STRING_POOL_TYPE        = 0x0001
  RES_TABLE_TYPE              = 0x0002

  # Chunk types in RES_XML_TYPE
  RES_XML_TYPE                = 0x0003
  RES_XML_FIRST_CHUNK_TYPE    = 0x0100
  RES_XML_START_NAMESPACE_TYPE= 0x0100
  RES_XML_END_NAMESPACE_TYPE  = 0x0101
  RES_XML_START_ELEMENT_TYPE  = 0x0102
  RES_XML_END_ELEMENT_TYPE    = 0x0103
  RES_XML_CDATA_TYPE          = 0x0104
  RES_XML_LAST_CHUNK_TYPE     = 0x017f

  # This contains a uint32_t array mapping strings in the string
  # pool back to resource identifiers.  It is optional.
  RES_XML_RESOURCE_MAP_TYPE   = 0x0180,

  # Chunk types in RES_TABLE_TYPE
  RES_TABLE_PACKAGE_TYPE      = 0x0200
  RES_TABLE_TYPE_TYPE         = 0x0201
  RES_TABLE_TYPE_SPEC_TYPE    = 0x0202
end

class AxmlReader
  include BinaryDataReader

  attr_accessor :io, :state
  # Scanner combinating style
  def initialize(io = STDIN); @io = io; end

  def self.start(args); args.each { |path| puts self.new(File.new(path)).struct.pretty_inspect }; end

  def struct(parse_type = AxmlResChunkTypes::RES_XML_TYPE, also = proc{})
    @state = "Check XML Header for #{parse_type}"

    type = readU16

    warn "Mismatch XML chunk type header, expecting #{parse_type} found #{type} " if parse_type != type

    header_size = readU16
    chunk_size = readU32
    skipNBytes(header_size - (2+2+4))

    also.call
  end
end

AxmlReader.start(ARGV) if $PROGRAM_NAME == __FILE__
