unit module GL;
use NativeCall;
constant $gllib = 'GL';
our constant COLOR_BUFFER_BIT = 0x00004000;

our constant    ARRAY_BUFFER = 0x8892;
our constant     STATIC_DRAW = 0x88E4;
our constant   VERTEX_SHADER = 0x8B31;
our constant FRAGMENT_SHADER = 0x8B30;

our constant SHADER_SOURCE_LENGTH = 0x8B88;
our constant INFO_LOG_LENGTH = 0x8B84;
our constant COMPILE_STATUS = 0x8B81;
our constant    LINK_STATUS = 0x8B82;

our constant FLOAT = 0x1406;
our constant FALSE = 0;
our constant TRUE  = 1;

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

our sub genVertexArrays(int32, uint32 is rw) is native($gllib) is symbol('glGenVertexArrays') {*}
our sub bindVertexArray(uint32)              is native($gllib) is symbol('glBindVertexArray') {*}
our sub genBuffers(int32, uint32 is rw)      is native($gllib) is symbol('glGenBuffers') {*}
our sub bindBuffer(int32, uint32) is native($gllib) is symbol('glBindBuffer') {*}
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


our sub vertexAttribPointer(uint32, int32, uint32, bool, uint32, Pointer)
  is native($gllib) is symbol('glVertexAttribPointer') {*}

our sub enableVertexAttribArray(uint32) is native($gllib) is symbol('glEnableVertexAttribArray') {*}


our sub drawArrays(uint32, uint32, uint32)       is native($gllib) is symbol('glDrawArrays') {*}
our sub viewport(uint32, uint32, uint32, uint32) is native($gllib) is symbol('glViewport')   {*}

our sub getError(--> uint32) is native($gllib) is symbol('glGetError') {*}
