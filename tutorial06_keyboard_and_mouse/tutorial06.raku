#!/usr/bin/env -S raku -I../lib
use lib <../lib>;
use GL;
use GLM;
use GLFW;
use GLEW;
use Shaders;
use Texture;
use Controls;

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

constant @uv = 
  0.000059, 0.000004,
  0.000103, 0.336048,
  0.335973, 0.335903,
  1.000023, 0.000013,
  0.667979, 0.335851,
  0.999958, 0.336064,
  0.667979, 0.335851,
  0.336024, 0.671877,
  0.667969, 0.671889,
  1.000023, 0.000013,
  0.668104, 0.000013,
  0.667979, 0.335851,
  0.000059, 0.000004,
  0.335973, 0.335903,
  0.336098, 0.000071,
  0.667979, 0.335851,
  0.335973, 0.335903,
  0.336024, 0.671877,
  1.000004, 0.671847,
  0.999958, 0.336064,
  0.667979, 0.335851,
  0.668104, 0.000013,
  0.335973, 0.335903,
  0.667979, 0.335851,
  0.335973, 0.335903,
  0.668104, 0.000013,
  0.336098, 0.000071,
  0.000103, 0.336048,
  0.000004, 0.671870,
  0.336024, 0.671877,
  0.000103, 0.336048,
  0.336024, 0.671877,
  0.335973, 0.335903,
  0.667969, 0.671889,
  1.000004, 0.671847,
  0.667979, 0.335851
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

  my $window = GLFW::createWindow(1024, 768, "Tutorial 06 - keyboard and mouse", Nil, Nil);
  unless $window { fail "Failed to open GLFW window."; }

  GLFW::makeContextCurrent($window);

  #$GLEW::experimental = True; # Needed for core profile?
  unless GLEW::init() == GLEW::OK { fail "Failed to initialize GLEW"; }

  GLFW::setInputMode $window, GLFW::STICKY_KEYS, GL::TRUE;
  GLFW::setInputMode $window, GLFW::CURSOR, GLFW::CURSOR_DISABLED;
  GLFW::pollEvents;
  GLFW::setCursorPos $window, (1024/2).Num, (768/2).Num;
  
  GL::clearColor(0.Num, 0.Num, .4.Num, 0.Num);
  GL::enable GL::DEPTH_TEST;

  GL::genVertexArrays(1, my uint32 $vertexArrayID);
  GL::bindVertexArray($vertexArrayID);

  my $programID = Shaders::Load(
      vertex-shader-source => "TransformVertexShader.vertexshader".IO.slurp,
    fragment-shader-source => "TextureFragmentShader.fragmentshader".IO.slurp
  );

  my $matrixUniformLocation   = GL::getUniformLocation $programID, "MVP";

  my @vertex-buffer-data := CArray[num32].new: @triangles.flat».Num;
  my @uv-buffer-data     := CArray[num32].new: @uv.flat».Num;

  my uint32 $vertexBuffer;
  GL::genBuffers(1, $vertexBuffer);
  GL::bindBuffer(GL::ARRAY_BUFFER, $vertexBuffer);
  GL::bufferData(GL::ARRAY_BUFFER, 4*@vertex-buffer-data.elems, @vertex-buffer-data, GL::STATIC_DRAW);

  my uint32 $uvBuffer;
  GL::genBuffers(1, $uvBuffer);
  GL::bindBuffer(GL::ARRAY_BUFFER, $uvBuffer);
  GL::bufferData(GL::ARRAY_BUFFER, 4*@uv-buffer-data.elems, @uv-buffer-data, GL::STATIC_DRAW);

  $*ERR.printf("loading texture...");
  my uint32 $textureId = Texture::DDS::load "uvtemplate.DDS".IO;
  $*ERR.printf(" done\n");

  my $myTextureSampler  = GL::getUniformLocation $programID, "myTextureSampler";

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

    GL::clear( GL::COLOR_BUFFER_BIT +| GL::DEPTH_BUFFER_BIT);

    GL::useProgram($programID);

    {
      my $*window = $window;
      Controls::computeMatricesFromInput;
      my $projection = $Controls::projection-matrix;
      my $view       = $Controls::view-matrix;
      my $model = GLM::mat4(1);
      my $MVP = $projection * $view * $model;
      GL::uniformMatrix4fv($matrixUniformLocation, 1, GL::FALSE, CArray[num32].new($MVP.flat));
    }

    GL::activeTexture(GL::TEXTURE0);
    GL::bindTexture(GL::TEXTURE_2D, $textureId);
    GL::uniform1i($myTextureSampler, 0);

    GL::enableVertexAttribArray(0);
    GL::bindBuffer(GL::ARRAY_BUFFER, $vertexBuffer);
    GL::vertexAttribPointer(0, 3, GL::FLOAT, GL::FALSE, 0, 0);

    GL::enableVertexAttribArray(1);
    GL::bindBuffer(GL::ARRAY_BUFFER, $uvBuffer);
    GL::vertexAttribPointer(1, 2, GL::FLOAT, GL::FALSE, 0, 0);

    GL::drawArrays(GL::TRIANGLES, 0, 3*@triangles.elems);

    GL::disableVertexAttribArray(0);
    GL::disableVertexAttribArray(1);
    
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
