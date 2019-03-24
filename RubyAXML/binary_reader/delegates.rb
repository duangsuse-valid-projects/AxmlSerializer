## BinaryDataReader misc delegates from IO
module BinaryDataReader
  def size; io.size; end
  def tell; io.tell; end
  def seek(pos); io.seek(pos); end

  def eof?; io.eof?; end
  def close; io.close; end
  def closed?; io.closed?; end
  def filename; io.filename; end
end
