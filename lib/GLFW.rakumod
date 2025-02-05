unit module GLFW;
use NativeCall;
constant $lib = ('glfw', v3);
our class Window  is repr('CPointer') {}
our class Monitor is repr('CPointer') {}

our constant RELEASE = 0;
our constant PRESS   = 1;
our constant REPEAT  = 2;

our constant SAMPLES = 0x0002100D;
our constant CONTEXT_VERSION_MAJOR = 0x00022002;
our constant CONTEXT_VERSION_MINOR = 0x00022003;
our constant OPENGL_PROFILE        = 0x00022008;
our constant OPENGL_CORE_PROFILE   = 0x00032001;

our constant CURSOR      = 0x00033001;
our constant STICKY_KEYS = 0x00033002;

our constant CURSOR_NORMAL   = 0x00034001;
our constant CURSOR_HIDDEN   = 0x00034002;
our constant CURSOR_DISABLED = 0x00034003;

our enum KEY_CODE (
  KEY_ESCAPE => 256,
  KEY_RIGHT  => 262,
  KEY_LEFT   => 263,
  KEY_DOWN   => 264,
  KEY_UP     => 265,
);

our sub init(--> int32)                                             is native($lib) is symbol('glfwInit')                  {*}
our sub terminate(--> int32)                                        is native($lib) is symbol('glfwTerminate')             {*}
our sub setErrorCallback(&callback (int32, Str))                    is native($lib) is symbol('glfwSetErrorCallback')      {*}
our sub createWindow(int32, int32, Str, Monitor, Window --> Window) is native($lib) is symbol('glfwCreateWindow')          {*}
our sub destroyWindow(Window)                                       is native($lib) is symbol('glfwDestroyWindow')         {*}
our sub makeContextCurrent(Window)                                  is native($lib) is symbol('glfwMakeContextCurrent')    {*}
our sub windowShouldClose(Window --> int32)                         is native($lib) is symbol('glfwWindowShouldClose')     {*}
our sub setWindowShouldClose(Window, Bool --> int32)                is native($lib) is symbol('glfwSetWindowShouldClose')  {*}
our sub pollEvents                                                  is native($lib) is symbol('glfwPollEvents')            {*}
our sub swapBuffers(Window)                                         is native($lib) is symbol('glfwSwapBuffers')           {*}
our sub getKey(Window, int32 --> int32)                             is native($lib) is symbol('glfwGetKey')                {*}
our sub getFramebufferSize(Window, uint32 is rw, uint32 is rw)        is native($lib) is symbol('glfwGetFramebufferSize')    {*}
          
our sub setInputMode(Window, int32, int32) is native($lib) is symbol('glfwSetInputMode') {*}

our sub windowHint(int32, int32) is native($lib) is symbol('glfwWindowHint') {*}


our sub getCursorPos(uint32, num64 is rw, num64 is rw) is native($lib) is symbol('glfwGetCursorPos') {*}
our sub setCursorPos(uint32, num64      , num64)       is native($lib) is symbol('glfwSetCursorPos') {*}


our sub getTime(--> num64)  is native($lib) is symbol('glfwGetTime') {*}
