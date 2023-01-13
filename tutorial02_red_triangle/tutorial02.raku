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

  my $window = GLFW::createWindow( 1024, 768, "Tutorial 02", Nil, Nil);

  unless $window {
    GLFW::terminate() and
      die "Failed to open GLFW window. If you have an Intel GPU, they are not 3.3 compatible. Try the 2.1 version of the tutorials.";
  }
  GLFW::makeContextCurrent($window);

  unless GLEW::init() == GLEW::OK {
    GLFW::terminate() and
      die "Failed to initialize GLEW";
  }

  GLFW::setInputMode($window, GLFW::STICKY_KEYS, GL::TRUE);
  
  GL::clearColor(0.0.Num, 0.0.Num, 0.4.Num, 0.0.Num);

  GL::genVertexArrays(1, my uint32 $vertexArrayID);
  GL::bindVertexArray($vertexArrayID);

  my $programID = Shaders::Load(
      vertex-shader-source =>   "SimpleVertexShader.vertexshader"  .IO.slurp,
    fragment-shader-source => "SimpleFragmentShader.fragmentshader".IO.slurp
  );

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

  my $fps;
  my Promise $main-loop .= new;
  start {
    until $main-loop.status ~~ Kept|Broken { sleep 1; $*ERR.printf("\rFPS=%5.0f", $fps); }
  }.then({ $*ERR.printf("\n") });

  repeat {
    LAST $main-loop.keep;
    my $entry = ENTER now;
    LEAVE $fps = 1/(now - $entry);

    GL::clear( GL::COLOR_BUFFER_BIT );

    GL::useProgram($programID);

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
