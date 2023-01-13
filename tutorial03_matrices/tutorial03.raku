#!/usr/bin/env -S raku -I../lib
use lib <../lib>;
use GL;
use GLM;
use GLFW;
use GLEW;
use Shaders;

sub MAIN {
  use NativeCall;
    
  die "Could not initialize GLFW" unless GLFW::init();

  GLFW::windowHint(GLFW::SAMPLES, 4);
  GLFW::windowHint(GLFW::CONTEXT_VERSION_MAJOR, 3);
  GLFW::windowHint(GLFW::CONTEXT_VERSION_MINOR, 3);
  GLFW::windowHint(GLFW::OPENGL_PROFILE, GLFW::OPENGL_CORE_PROFILE);

  my $window = GLFW::createWindow( 1024, 768, "Tutorial 03 - Matrices", Nil, Nil);
  unless $window {
    GLFW::terminate() and
      die "Failed to open GLFW window. If you have an Intel GPU, they are not 3.3 compatible. Try the 2.1 version of the tutorials.";
  }
  GLFW::makeContextCurrent($window);

  #$GLEW::experimental = True; # Needed for core profile?
  unless GLEW::init() == GLEW::OK {
    GLFW::terminate() and
      die "Failed to initialize GLEW";
  }

  GLFW::setInputMode($window, GLFW::STICKY_KEYS, GL::TRUE);
  
  GL::clearColor(0.Num, 0.Num, .4.Num, 0.Num);

  GL::genVertexArrays(1, my uint32 $vertexArrayID);
  GL::bindVertexArray($vertexArrayID);

  my $programID = Shaders::Load(
      vertex-shader-source => "SimpleTransform.vertexshader".IO.slurp,
    fragment-shader-source => "SingleColor.fragmentshader".IO.slurp
  );

  my $matrixID = GL::getUniformLocation $programID, "MVP";

  my $projection = GLM::perspective(45.0°, 4/3, .1 .. 100);
  my $view       = GLM::lookAt
    eye    => GLM::vec3(4, 3, 3),
	   center => GLM::vec3(0, 0, 0),
	   up     => GLM::vec3(0, 1, 0)
	     ;
  my $model = GLM::mat4(1);
  my $MVP = $projection * $view * $model;

  my @vertex-buffer-data := CArray[num32].new;
  @vertex-buffer-data[$++] = .Num for
    -1.0, -1.0, 0.0,
    1.0, -1.0, 0.0,
    0.0,  1.0, 0.0,
    ;

  my uint32 $vertexBuffer;
  GL::genBuffers(1, $vertexBuffer);
  GL::bindBuffer(GL::ARRAY_BUFFER, $vertexBuffer);
  GL::bufferData(GL::ARRAY_BUFFER, 4*@vertex-buffer-data.elems, @vertex-buffer-data, GL::STATIC_DRAW);

  repeat {

    GL::clear( GL::COLOR_BUFFER_BIT );

    GL::useProgram($programID);

    GL::uniformMatrix4fv($matrixID, 1, GL::FALSE, CArray[num32].new($MVP.flat));

    GL::enableVertexAttribArray(0);
    GL::bindBuffer(GL::ARRAY_BUFFER, $vertexBuffer);
    GL::vertexAttribPointer(
      0,
      3,
      GL::FLOAT,
      GL::FALSE,
      0,
      0
    );

    GL::drawArrays(GL::TRIANGLES, 0, 3);

    GL::disableVertexAttribArray(0);
    
    GLFW::swapBuffers($window); 
    GLFW::pollEvents();

  } while GLFW::getKey($window, GLFW::KEY_ESCAPE) !== GLFW::PRESS &&
	    GLFW::windowShouldClose($window) == 0;
  
  # Cleanup VBO
  GL::deleteBuffers(1, $vertexBuffer);
  GL::deleteVertexArrays(1, $vertexArrayID);
  GL::deleteProgram($programID);

  GLFW::terminate();

}
