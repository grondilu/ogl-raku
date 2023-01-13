#!/usr/bin/env -S raku -I../lib
use lib <../lib>;
use GL;
use GLM;
use GLFW;
use GLEW;

sub MAIN {

  unless GLFW::init() {
    
    die "Could not initialize GLFW";

  }

  GLFW::windowHint(GLFW::SAMPLES, 4);
  GLFW::windowHint(GLFW::CONTEXT_VERSION_MAJOR, 3);
  GLFW::windowHint(GLFW::CONTEXT_VERSION_MINOR, 3);
  GLFW::windowHint(GLFW::OPENGL_PROFILE, GLFW::OPENGL_CORE_PROFILE);

  my $window = GLFW::createWindow( 1024, 768, "Tutorial 01", Nil, Nil);

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

  repeat {

    GL::clear( GL::COLOR_BUFFER_BIT );

    GLFW::swapBuffers($window); 
    GLFW::pollEvents();
  } while GLFW::getKey($window, GLFW::KEY_ESCAPE) !== GLFW::PRESS &&
	    GLFW::windowShouldClose($window) == 0;
  

  GLFW::terminate();

}
