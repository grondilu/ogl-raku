#!/usr/bin/env -S raku -I../lib
use lib <../lib>;
use GL;
use GLM;
use GLFW;
use GLEW;
use Shaders;

constant @triangles = 
<
    -1 -1 -1 
    -1 -1 1 
    -1 1 1 
     1 1 -1 
    -1 -1 -1 
    -1 1 -1 
     1 -1 1 
    -1 -1 -1 
     1 -1 -1 
     1 1 -1 
     1 -1 -1 
    -1 -1 -1 
    -1 -1 -1 
    -1 1 1 
    -1 1 -1 
     1 -1 1 
    -1 -1 1 
    -1 -1 -1 
    -1 1 1 
    -1 -1 1 
     1 -1 1 
     1 1 1 
     1 -1 -1 
     1 1 -1 
     1 -1 -1 
     1 1 1 
     1 -1 1 
     1 1 1 
     1 1 -1 
    -1 1 -1 
     1 1 1 
    -1 1 -1 
    -1 1 1 
     1 1 1 
    -1 1 1 
     1 -1 1
>.rotor(3);

constant @colors =
  0.583,  0.771,  0.014,
  0.609,  0.115,  0.436,
  0.327,  0.483,  0.844,
  0.822,  0.569,  0.201,
  0.435,  0.602,  0.223,
  0.310,  0.747,  0.185,
  0.597,  0.770,  0.761,
  0.559,  0.436,  0.730,
  0.359,  0.583,  0.152,
  0.483,  0.596,  0.789,
  0.559,  0.861,  0.639,
  0.195,  0.548,  0.859,
  0.014,  0.184,  0.576,
  0.771,  0.328,  0.970,
  0.406,  0.615,  0.116,
  0.676,  0.977,  0.133,
  0.971,  0.572,  0.833,
  0.140,  0.616,  0.489,
  0.997,  0.513,  0.064,
  0.945,  0.719,  0.592,
  0.543,  0.021,  0.978,
  0.279,  0.317,  0.505,
  0.167,  0.620,  0.077,
  0.347,  0.857,  0.137,
  0.055,  0.953,  0.042,
  0.714,  0.505,  0.345,
  0.783,  0.290,  0.734,
  0.722,  0.645,  0.174,
  0.302,  0.455,  0.848,
  0.225,  0.587,  0.040,
  0.517,  0.713,  0.338,
  0.053,  0.959,  0.120,
  0.393,  0.621,  0.362,
  0.673,  0.211,  0.457,
  0.820,  0.883,  0.371,
  0.982,  0.099,  0.879
;

sub MAIN {
  use NativeCall;
    
  die "Could not initialize GLFW" unless GLFW::init();
  LEAVE {
    note "Terminating GLFW";
    GLFW::terminate();
  }

  GLFW::windowHint(GLFW::SAMPLES, 4);
  GLFW::windowHint(GLFW::CONTEXT_VERSION_MAJOR, 3);
  GLFW::windowHint(GLFW::CONTEXT_VERSION_MINOR, 3);
  GLFW::windowHint(GLFW::OPENGL_PROFILE, GLFW::OPENGL_CORE_PROFILE);

  my $window = GLFW::createWindow(1024, 768, "Tutorial 04 - Colored Cube", Nil, Nil);
  unless $window { fail "Failed to open GLFW window."; }

  GLFW::makeContextCurrent($window);

  #$GLEW::experimental = True; # Needed for core profile?
  unless GLEW::init() == GLEW::OK { fail "Failed to initialize GLEW"; }

  GLFW::setInputMode($window, GLFW::STICKY_KEYS, GL::TRUE);
  
  GL::clearColor(0.Num, 0.Num, .4.Num, 0.Num);

  GL::genVertexArrays(1, my uint32 $vertexArrayID);
  GL::bindVertexArray($vertexArrayID);

  my $programID = Shaders::Load(
      vertex-shader-source => "TransformVertexShader.vertexshader".IO.slurp,
    fragment-shader-source => "ColorFragmentShader.fragmentshader".IO.slurp
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

  my @vertex-buffer-data := CArray[num32].new: @triangles.flat».Num;
  my  @color-buffer-data := CArray[num32].new: @colors.flat».Num;

  # TODO: find a way to generate several buffers in one call
  my uint32 ($vertexBuffer, $colorBuffer);
  GL::genBuffers(1, $vertexBuffer);
  GL::bindBuffer(GL::ARRAY_BUFFER, $vertexBuffer);
  GL::bufferData(GL::ARRAY_BUFFER, 4*@vertex-buffer-data.elems, @vertex-buffer-data, GL::STATIC_DRAW);
  GL::genBuffers(1, $colorBuffer);
  GL::bindBuffer(GL::ARRAY_BUFFER, $colorBuffer);
  GL::bufferData(GL::ARRAY_BUFFER, 4*@color-buffer-data.elems, @color-buffer-data, GL::STATIC_DRAW);

  my Promise $main-loop .= new;
  my Instant $now;
  my $fps;
  my $fps-counter = start {
    until $main-loop.status ~~ Kept|Broken {
      sleep .1; $*ERR.printf("\rFPS:%3.0f", $fps);
    }
    $*ERR.printf("\n");
  }
  repeat {
    ENTER $now = now;
    NEXT $fps = 1/(now - $now);
    LAST { $main-loop.keep; await $fps-counter; }

    GL::clear( GL::COLOR_BUFFER_BIT );

    GL::useProgram($programID);

    GL::uniformMatrix4fv($matrixID, 1, GL::FALSE, CArray[num32].new($MVP.flat));

    GL::enableVertexAttribArray(0);
    GL::bindBuffer(GL::ARRAY_BUFFER, $vertexBuffer);
    GL::vertexAttribPointer(0, 3, GL::FLOAT, GL::FALSE, 0, 0);

    GL::enableVertexAttribArray(1);
    GL::bindBuffer(GL::ARRAY_BUFFER, $colorBuffer);
    GL::vertexAttribPointer(1, 3, GL::FLOAT, GL::FALSE, 0, 0);

    GL::drawArrays(GL::TRIANGLES, 0, 3*@triangles.elems);

    GL::disableVertexAttribArray(0);
    
    GLFW::swapBuffers($window); 
    GLFW::pollEvents();

  } while GLFW::getKey($window, GLFW::KEY_ESCAPE) !== GLFW::PRESS &&
	    GLFW::windowShouldClose($window) == 0;
  
  # Cleanup VBO
  note "Cleaning VBO";
  GL::deleteBuffers(1, $vertexBuffer);
  GL::deleteVertexArrays(1, $vertexArrayID);

  note "Deleting program";
  GL::deleteProgram($programID);

}
