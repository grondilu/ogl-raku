unit module BMP;

our sub load(blob8 $blob) {
  my blob8 $header = $blob.subbuf: 0, 54;
  fail "wrong magic number" unless $header.subbuf(0, 2).decode eq 'BM';
  #fail "Not a correct BMP file" unless $header.read-int32(0x1E, LittleEndian) == 0;
  #fail "Not a correct BMP file" unless $header.read-int32(0x24, LittleEndian) == 24;
  my UInt $file-size = $header.read-uint32(2, LittleEndian);
  fail "unexpected file size" unless $file-size == $blob.bytes;
  my UInt $dataPos = $header.read-uint32(10, LittleEndian);
  my UInt $width      = $header.read-uint32(0x12, LittleEndian);
  my UInt $height     = $header.read-uint32(0x16, LittleEndian);
  my blob8 $data  = $blob.subbuf: $dataPos;
  die "unexpected data length" unless $width*$height*3 == $data.bytes;
  Array[UInt].new: :shape($width, $height, 3), $data.rotor(3).rotor($height);
}
