unit module Controls;
use GLM;
use GLFW;

sub direction(Real $vertical-angle, Real $horizontal-angle) {
  GLM::vec3
    cos($vertical-angle)*cos($horizontal-angle),
    sin($vertical-angle),
    cos($vertical-angle)*sin($horizontal-angle)
  ;
}

my $horizontal-angle = 45°;
my $vertical-angle   = 15°;
my $position = 10*direction($vertical-angle, $horizontal-angle);
my $initial-fov      = 45°;

our $projection-matrix = GLM::perspective $initial-fov, 3/4, .1 .. 100;
our $view-matrix = GLM::mat4 1;
my $speed = 0.001;
my $mouse-speed = .0005;

our sub computeMatricesFromInput {
  state $last-time = GLFW::getTime;
  
  my $current-time = GLFW::getTime;
  my $delta-time   = $current-time - $last-time;

  my num64 ($xpos, $ypos);
  GLFW::getCursorPos($*window, $xpos, $ypos);

  GLFW::setCursorPos($*window, (1024/2).Num, (768/2).Num);

  $horizontal-angle += $mouse-speed*(1024/2 - $xpos);
  $vertical-angle   += $mouse-speed*( 768/2 - $ypos);

  my $direction = direction $vertical-angle, $horizontal-angle;
  my $right = GLM::vec3
    sin($horizontal-angle - pi/2),
    0,
    cos($horizontal-angle - pi/2)
  ;
  my $up = $right × $direction;

  $position += $delta-time * $speed * $direction if GLFW::getKey($*window, GLFW::KEY_UP   ) == GLFW::PRESS;
  $position -= $delta-time * $speed * $direction if GLFW::getKey($*window, GLFW::KEY_DOWN ) == GLFW::PRESS;
  $position += $delta-time * $speed * $right     if GLFW::getKey($*window, GLFW::KEY_RIGHT) == GLFW::PRESS;
  $position -= $delta-time * $speed * $right     if GLFW::getKey($*window, GLFW::KEY_LEFT ) == GLFW::PRESS;

  my $fov = $initial-fov;
  $projection-matrix = GLM::perspective $initial-fov, 4/3, .1 .. 100;
  $view-matrix = GLM::lookAt eye => $position, center => $position-$direction, :$up;

}
