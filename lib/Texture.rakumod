unit module Texture;

our constant FOURCC_DXT1 = 0x31545844; # Equivalent to "DXT1" in ASCII
our constant FOURCC_DXT3 = 0x33545844; # Equivalent to "DXT3" in ASCII
our constant FOURCC_DXT5 = 0x35545844; # Equivalent to "DXT5" in ASCII

our package DDS {
  our sub load(IO::Path $image-path --> UInt) {
    use GL;
    use NativeCall; # (for nativecast)

    my $fh = $image-path.open: :r, :b;

    # verify file code
    fail "wrong file type" unless $fh.read(4).decode('ascii') eq 'DDS ';

    my $header = $fh.read: 124;

    my uint32 (
      $height,
      $width,
      $linearSize,
      $mipMapCount,
      $fourCC
    ) = map { $header.read-uint32($_) }, 8, 12, 16, 24, 80;

    my $bufsize = $mipMapCount > 1 ?? $linearSize * 2 !! $linearSize; 
    my $array-buffer = CArray[uint8].allocate($bufsize);
    $array-buffer[$++] = $_ for $fh.read($bufsize).list;
    my Pointer[void] $buffer = nativecast(Pointer[void], $array-buffer);
    $fh.close;

    #my $components = ...?
    my uint32 $format;
    given $fourCC {
      when FOURCC_DXT1 { note "FOURCC_DXT1"; $format = GL::COMPRESSED_RGBA_S3TC_DXT1_EXT; }
      when FOURCC_DXT3 { note "FOURCC_DXT3"; $format = GL::COMPRESSED_RGBA_S3TC_DXT3_EXT; }
      when FOURCC_DXT5 { note "FOURCC_DXT5"; $format = GL::COMPRESSED_RGBA_S3TC_DXT5_EXT; }
      default { note "unexpected texture format"; return 0; }
    }
    my uint32 $textureID;
    GL::genTextures(1, $textureID);

    GL::bindTexture(GL::TEXTURE_2D, $textureID);
    GL::pixelStorei(GL::UNPACK_ALIGNMENT, 1);

    my $blockSize = ($format == GL::COMPRESSED_RGBA_S3TC_DXT1_EXT) ?? 8 !! 16; 
    my $offset = 0;

    note "format is $format";
    note "bufsize is $bufsize";
    note "blockSize is $blockSize";
    note "mipMapCount is $mipMapCount";

    loop (my int32 $level = 0; $level < $mipMapCount && ($width || $height); ++$level) {
      my $size = (($width+3) div 4)*(($height+3) div 4)*$blockSize; 
      note "level $level/$mipMapCount: $width x $height, size is $size";
      GL::compressedTexImage2D
	GL::TEXTURE_2D,
	$level,
	$format,
	$width, $height,  0,
	$size,
	$buffer + $offset
	; 
      $offset += $size;
      $width div= 2;
      $height div= 2;

      $width  = 1 if $width < 1;
      $height = 1 if $height < 1;
    }
 
    return $textureID;
  }
}
