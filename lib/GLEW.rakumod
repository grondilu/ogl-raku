unit module GLEW;

use NativeCall;

constant $lib = 'GLEW';

our constant OK = 0;

our sub init(--> uint32) is native($lib) is symbol('glewInit') {*}
