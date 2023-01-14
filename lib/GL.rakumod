unit module GL;
use NativeCall;
constant $gllib = 'GL';

our constant COLOR_BUFFER_BIT = 0x00004000;
our constant DEPTH_BUFFER_BIT = 0x00000100;

our constant UNPACK_ALIGNMENT = 0x0CF5;

our constant COMPRESSED_RGBA_S3TC_DXT1_EXT = 0x83F1;
our constant COMPRESSED_RGBA_S3TC_DXT3_EXT = 0x83F2;
our constant COMPRESSED_RGBA_S3TC_DXT5_EXT = 0x83F3;

our constant    ARRAY_BUFFER = 0x8892;
our constant     STATIC_DRAW = 0x88E4;
our constant   VERTEX_SHADER = 0x8B31;
our constant FRAGMENT_SHADER = 0x8B30;
our constant      TEXTURE_2D = 0x0DE1;

our constant SHADER_SOURCE_LENGTH = 0x8B88;
our constant INFO_LOG_LENGTH = 0x8B84;
our constant COMPILE_STATUS = 0x8B81;
our constant    LINK_STATUS = 0x8B82;

our constant UNSIGNED_BYTE = 0x1401;
our constant FLOAT         = 0x1406;

our constant RGB   = 0x1907;
our constant RGBA  = 0x1908;

our constant NEAREST = 0x2600;

our constant TEXTURE_MAG_FILTER = 0x2800;
our constant TEXTURE_MIN_FILTER = 0x2801;

our constant TEXTURE0	= 0x84C0;
our constant TEXTURE1	= 0x84C1;
our constant TEXTURE2	= 0x84C2;
our constant TEXTURE3	= 0x84C3;
our constant TEXTURE4	= 0x84C4;
our constant TEXTURE5	= 0x84C5;
our constant TEXTURE6	= 0x84C6;
our constant TEXTURE7	= 0x84C7;
our constant TEXTURE8	= 0x84C8;
our constant TEXTURE9	= 0x84C9;
our constant TEXTURE10	= 0x84CA;
our constant TEXTURE11	= 0x84CB;
our constant TEXTURE12	= 0x84CC;
our constant TEXTURE13	= 0x84CD;
our constant TEXTURE14	= 0x84CE;
our constant TEXTURE15	= 0x84CF;
our constant TEXTURE16	= 0x84D0;
our constant TEXTURE17	= 0x84D1;
our constant TEXTURE18	= 0x84D2;
our constant TEXTURE19	= 0x84D3;
our constant TEXTURE20	= 0x84D4;
our constant TEXTURE21	= 0x84D5;
our constant TEXTURE22	= 0x84D6;
our constant TEXTURE23	= 0x84D7;
our constant TEXTURE24	= 0x84D8;
our constant TEXTURE25	= 0x84D9;
our constant TEXTURE26	= 0x84DA;
our constant TEXTURE27	= 0x84DB;
our constant TEXTURE28	= 0x84DC;
our constant TEXTURE29	= 0x84DD;
our constant TEXTURE30	= 0x84DE;
our constant TEXTURE31	= 0x84DF;

our constant FALSE = 0;
our constant TRUE  = 1;

our constant BGR   = 0x80E0;
our constant BGRA  = 0x80E1;

our enum PrimitiveMode(
  POINTS         => 0x0000,
  LINES          => 0x0001,
  LINE_LOOP      => 0x0002,
  LINE_STRIP     => 0x0003,
  TRIANGLES      => 0x0004,
  TRIANGLE_STRIP => 0x0005,
  TRIANGLE_FAN   => 0x0006,
  QUADS          => 0x0007,
  QUAD_STRIP     => 0x0008,
  POLYGON        => 0x0009
);

our enum MatrixMode(
  MATRIX_MODE => 0x0BA0,
  MODELVIEW   => 0x1700,
  PROJECTION  => 0x1701,
  TEXTURE     => 0x1702
);

our sub clearColor(num32, num32, num32, num32) is native($gllib) is symbol('glClearColor') {*}
our sub clear(int32) is native($gllib) is symbol('glClear') {*}

our sub genVertexArrays(int32, uint32 is rw)    is native($gllib) is symbol('glGenVertexArrays') {*}
our sub deleteVertexArrays(int32, uint32 is rw) is native($gllib) is symbol('glDeleteVertexArrays') {*}
our sub bindVertexArray(uint32)                 is native($gllib) is symbol('glBindVertexArray') {*}

our sub genBuffers(int32, uint32 is rw)                 is native($gllib) is symbol('glGenBuffers') {*}
our sub deleteBuffers(int32, uint32 is rw)              is native($gllib) is symbol('glDeleteBuffers') {*}
our sub bindBuffer(int32, uint32)                       is native($gllib) is symbol('glBindBuffer') {*}
our sub bufferData(int32, uint32, CArray[num64], int32) is native($gllib) is symbol('glBufferData') {*}

our sub createShader(uint32 --> uint32) is native($gllib) is symbol('glCreateShader') {*}
our sub deleteShader(uint32)            is native($gllib) is symbol('glDeleteShader') {*}
our sub shaderSource(uint32, uint32, CArray[Str], int32) is native($gllib) is symbol('glShaderSource') {*}
our sub compileShader(uint32) is native($gllib) is symbol('glCompileShader') {*}

our sub getShaderiv(uint32, uint32, int32 is rw) is native($gllib) is symbol('glGetShaderiv') {*}
our sub getShaderInfoLog(uint32, uint32, uint32, CArray[uint8]) is native($gllib) is symbol('glGetShaderInfoLog') {*}
our sub getProgramiv(uint32, uint32, int32 is rw) is native($gllib) is symbol('glGetProgramiv') {*}
our sub getProgramInfoLog(uint32, uint32, uint32, CArray[uint8]) is native($gllib) is symbol('glGetProgramInfoLog') {*}


our sub createProgram(--> uint32)     is native($gllib) is symbol('glCreateProgram') {*}
our sub attachShader(uint32, uint32)  is native($gllib) is symbol('glAttachShader') {*}
our sub linkProgram (uint32)          is native($gllib) is symbol('glLinkProgram' ) {*}
our sub useProgram  (uint32)          is native($gllib) is symbol('glUseProgram')   {*}
our sub deleteProgram(uint32)         is native($gllib) is symbol('glDeleteProgram') {*}


our sub vertexAttribPointer(uint32, int32, uint32, bool, uint32, Pointer)
  is native($gllib) is symbol('glVertexAttribPointer') {*}

our sub  enableVertexAttribArray(uint32) is native($gllib) is symbol('glEnableVertexAttribArray') {*}
our sub disableVertexAttribArray(uint32) is native($gllib) is symbol('glDisableVertexAttribArray') {*}


our sub drawArrays(uint32, uint32, uint32)       is native($gllib) is symbol('glDrawArrays') {*}
our sub viewport(uint32, uint32, uint32, uint32) is native($gllib) is symbol('glViewport')   {*}

our sub getError(--> uint32) is native($gllib) is symbol('glGetError') {*}

our sub getUniformLocation(uint32, Str --> uint32) is native($gllib) is symbol('glGetUniformLocation') {*}

our sub uniformMatrix4fv(uint32, uint32, Bool, CArray[num32]) is native($gllib) is symbol('glUniformMatrix4fv') {*}


our sub genTextures(uint32, uint32 is rw) is native($gllib) is symbol('glGenTextures') {*}
our sub bindTexture(uint32, uint32)       is native($gllib) is symbol('glBindTexture') {*}
our sub texImage2D(uint32 $target, int32 $level,
  int32 $internalFormat, uint32 $width, uint32 $height, 
  int32 $border, uint32 $format, uint32 $type,
  Pointer[void]) is native($gllib) is symbol('glTexImage2D') {*}


our sub texParameteri(uint32, uint16, uint16) is native($gllib) is symbol('glTexParameteri') {*}


our sub activeTexture(uint16) is native($gllib) is symbol('glActiveTexture') {*}

our sub uniform1i(int32, int32) is native($gllib) is symbol('glUniform1i') {*}

our sub pixelStorei(uint16, int32) is native($gllib) is symbol('glPixelStorei') {*}

our sub compressedTexImage2D(uint32 $target,
  int32 $level, uint32 $internalFormat, uint32 $width, uint32 $height,
  int32 $border, uint32 $imageSize, Pointer[void] $data) is native($gllib) is symbol('glCompressedTexImage2D') {*}
