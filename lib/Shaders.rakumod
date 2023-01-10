unit module Shaders;
use GL;

my subset Type of UInt where GL::VERTEX_SHADER | GL::FRAGMENT_SHADER;

our sub Load(
  Str :$vertex-shader-source,
  Str :$fragment-shader-source
) returns uint32 {
  use NativeCall;
  my uint32 $programID = GL::createProgram();

  # Create the shaders
  my uint32 $vertexShaderID   = GL::createShader(GL::VERTEX_SHADER);
  my uint32 $fragmentShaderID = GL::createShader(GL::FRAGMENT_SHADER);

  my int32 $result;
  my int32 $infoLogLength;

  note "Compiling vertex shader";
  my @vertexShaderSources := CArray[Str].new;
  @vertexShaderSources[0] = $vertex-shader-source;
  GL::shaderSource($vertexShaderID, 1, @vertexShaderSources, Nil);
  GL::compileShader($vertexShaderID);

  # Check Vertex Shader
  GL::getShaderiv($vertexShaderID, GL::COMPILE_STATUS, $result);
  GL::getShaderiv($vertexShaderID, GL::INFO_LOG_LENGTH, $infoLogLength);
  if $infoLogLength > 0 {
    my $infoLog = CArray[uint8].allocate($infoLogLength);
    GL::getShaderInfoLog($vertexShaderID, $infoLogLength, Nil, $infoLog);
    note blob8.new($infoLog.list[0..^($infoLogLength - 1)]).decode('ascii');
  }

  note "Compiling fragment shader";
  my @fragmentShaderSources := CArray[Str].new;
  @fragmentShaderSources[0] = $fragment-shader-source;
  GL::shaderSource($fragmentShaderID, 1, @fragmentShaderSources, Nil);
  GL::compileShader($fragmentShaderID);

  # Check Fragment Shader
  GL::getShaderiv($fragmentShaderID, GL::COMPILE_STATUS, $result);
  GL::getShaderiv($fragmentShaderID, GL::INFO_LOG_LENGTH, $infoLogLength);
  if $infoLogLength > 0 {
    my $infoLog = CArray[uint8].allocate($infoLogLength);
    GL::getShaderInfoLog($fragmentShaderID, $infoLogLength, Nil, $infoLog);
    note blob8.new($infoLog.list[0..^($infoLogLength - 1)]).decode('ascii');
  }

  note "Linking program";
  GL::attachShader($programID, $vertexShaderID);
  GL::attachShader($programID, $fragmentShaderID);
  GL::linkProgram($programID);

  # Check Program
  GL::getProgramiv($programID, GL::LINK_STATUS, $result);
  GL::getProgramiv($programID, GL::INFO_LOG_LENGTH, $infoLogLength);
  if $infoLogLength > 0 {
    my $infoLog = CArray[uint8].allocate($infoLogLength);
    GL::getProgramInfoLog($programID, $infoLogLength, Nil, $infoLog);
    note blob8.new($infoLog.list[0..^($infoLogLength - 1)]).decode('ascii');
  }

  GL::deleteShader($vertexShaderID);
  GL::deleteShader($fragmentShaderID);

  return $programID;
}
