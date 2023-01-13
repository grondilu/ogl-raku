unit module GLM;
class array is Array[Real] {...}

subset Matrix of array where { .shape.elems == 2 }
subset Vector of array where { .shape.elems == 1 }

subset Mat2 of Matrix where { .shape ~~ (2, 2) }
subset Mat3 of Matrix where { .shape ~~ (3, 3) }
subset Mat4 of Matrix where { .shape ~~ (4, 4) }

subset Vec2 of Vector where { .shape ~~ (2,) }
subset Vec3 of Vector where { .shape ~~ (3,) }
subset Vec4 of Vector where { .shape ~~ (4,) }

class array {
  method x(           Vector:) { self[0] }
  method y(           Vector:) { self[1] }
  method z($ where Vec3|Vec4:) { self[2] }
  method w(             Vec4:) { self[3] }
  method xy(Vector:) { self.x, self.y }
  method xyz(Vector:) { self.x, self.y, self.z }
  method xyzw(Vec4:) { self.x, self.y, self.z, self.w }
}

our sub vec2(Real $x, Real $y                   --> Vec2) { array.new: :shape(2,), ($x, $y) }
our sub vec3(Real $x, Real $y, Real $z          --> Vec3) { array.new: :shape(3,), ($x, $y, $z) }
our sub vec4(Real $x, Real $y, Real $z, Real $w --> Vec4) { array.new: :shape(4,), ($x, $y, $z, $w) }

our sub mat2(*@x where @x == 4  --> Mat2) { array.new: :shape(2,2), @x.rotor(2) }
our sub mat3(*@x where @x == 9  --> Mat3) { array.new: :shape(3,3), @x.rotor(3) }
our proto mat4(| --> Mat4) {*}
multi mat4(*@x where @x == 16 --> Mat4) { array.new: :shape(4,4), @x.rotor(4) }
multi mat4(1 --> Mat4) { array.new: :shape(4,4), (^4).map({(1,0,0,0).rotate(-$_)}) }

multi infix:<+>(Vector $u, Vector $v where $u.shape ~~ $v.shape --> Vector) is export { array.new: shape => $u.shape, (@$u Z+ @$v) }
multi infix:<*>(Real $r, Vector $v --> Vector) is export { array.new: shape => $v.shape, ($r X* $v.list) }
multi infix:</>(Vector $v, Real $r --> Vector) is export { array.new: shape => $v.shape, ($v.list X/ $r) }
multi prefix:<->(Vector $v --> Vector) is export { -1*$v }
multi infix:<->(Vector $u, Vector $v where $u.shape ~~ $v.shape --> Vector) is export { $u + -$v }

sub infix:<·>(Vector $u, Vector $v) returns Real is tighter(&[*]) is export { [+] @$u »*« @$v }
multi infix:<×>(Vec3 $u, Vec3 $v --> Vec3) is export {
  vec3 
    $u[1]*$v[2] - $u[2]*$v[1],
    $u[2]*$v[0] - $u[0]*$v[2],
    $u[0]*$v[1] - $u[1]*$v[0]
}
our sub norm(Vector $v --> Real) { sqrt $v·$v }
our sub normalized(Vector $v --> Vector) { $v/norm($v) }

multi infix:<+>(Matrix $a, Matrix $b where $a.shape ~~ $b.shape --> Matrix) is export {
  array.new: shape => $a.shape,
    map -> $i { map -> $j { $a[$i;$j] + $b[$i; $j] }, ^$a.shape[1] }, ^$a.shape[0];
}
multi infix:<*>(Matrix $m, Vector $v where $m.shape[1] == $v.shape[0] --> Vector) is export {
  #"Partially dimensioned views of shaped arrays not yet implemented."
  #my Real @p[$v.elems] = map { [+] $m[$_; *] »*« $v[*] }, ^$m.shape[0];
  array.new:
    shape => $v.shape,
    map -> $i {
    my @r = map -> $j { $m[$i; $j] }, ^$m.shape[1];
    [+] @r »*« @$v;
  }, ^$m.shape[0];
}
multi infix:<*>(Matrix $A, Matrix $B where $A.shape[0] == $B.shape[1] --> Matrix) is export {
  # In GLSL matrices are in column-major order!
  my array $C .= new: :shape($A.shape[1], $B.shape[0]);
  for ^$A.shape[1] X ^$B.shape[0] -> ($i, $j) {
    my @r = map { $A[$_; $i] }, ^$A.shape[0];
    my @c = map { $B[$j; $_] }, ^$B.shape[1];
    $C[$j;$i] = [+] @r »*« @c;
  }
  $C
}

sub postfix:<°>(Real $angle --> Real) is export { $angle/180*π }
sub postfix:<⁰>($) is export { fail "Did you mean postfix:<°> instead of postfix:<⁰>?" }

our sub perspective(Real $fovy, Rat  $aspect, Range $range) returns Mat4 {
  my $tan = tan($fovy/2);
  my ($n, $f) = $range.minmax;
  # Right-Handed, Negative Origin (RH-NO)
  mat4
    1/($aspect*$tan),         0,                     0,  0,
                   0,    1/$tan,                     0,  0,
                   0,         0,      -($f+$n)/($f-$n), -1,
                   0,         0,    -(2*$f*$n)/($f-$n),  0
}

our sub lookAt(Vec3 :eye($e), Vec3 :$center, Vec3 :$up) returns Mat4 {
  my $f = normalized($e - $center);
  my $s = normalized($up × $f);
  my $u = $f × $s;
  mat4
     $s[0],   $u[0],   $f[0],   0,
     $s[1],   $u[1],   $f[1],   0,
     $s[2],   $u[2],   $f[2],   0,
    -$s·$e,  -$u·$e,  -$f·$e,   1,
}

