/*
 * Various flute-making tools
 */
include <consts.scad>;

// round up n to nearest positive multiple of 4
function roundup(n) = max(ceil(n/4)*4, 4);

// used to calculate number of polygon segments ($fn) given the diameter
function fns(b) = roundup(PI*b/NOZZLE_DIAMETER);

// used to calculate diameter of circumscribed polygon
function cir(b, fn) = let(n = fn ? fn : fns(b)) 1/cos(180/n)*b;

// used to calculate circumscribed polygon with arc compensation
function arc(b, fn) = sqrt(pow(NOZZLE_DIAMETER,2) + 4*pow(cir(b, fn)/2,2));

// translate +z axis
module slide(z=LAYER_HEIGHT) {
  translate([0,0,z]) children();
}

// rotate x by 90, and z by r (for holes)
module pivot(r=0) {
  rotate([90,0,r]) children();
}

// scale into an oval with specified diameter and width
module ovalize(d, w) {
  scale([1,w/d,1]) children();
}

// minkowski sum children with a square of width sq
module squarify(sq) {
  if (sq > 0) minkowski() {
    children();
    cube([sq,sq,0.00001], center=true);
  } else children();
}

// Frustum circumscribes a truncated cone
module frustum(z=0, b=NOZZLE_DIAMETER, b2, l=LAYER_HEIGHT) {
  b2 = (b2==undef) ? b : b2;
  fn = fns(max(b, b2)); // adaptive resolution
  slide(z) cylinder(d1=arc(b, fn), d2=arc(b2, fn), h=l, $fn=fn);
}

// tube: difference of two frustums
module tube(z=0, b=NOZZLE_DIAMETER, b2, l=LAYER_HEIGHT, h=NOZZLE_DIAMETER, h2) {
  b2 = (b2==undef) ? b : b2;
  h2 = (h2==undef) ? h : h2;
  difference() {
    frustum(z=z, b=b+2*h, b2=b2+2*h2, l=l);
    frustum(z=z, b=b, b2=b2, l=l);
  }
}

// tone or embouchure hole
// (b)ore (h)eight (d)iameter (w)idth (r)otate° w(a)ll°
// (s)houlder° (sq)areness
module hole(z=0, b, h, d, w, r=0, a=0, s=0, sq=0) {
  w = w==undef ? d : w;
  rh = arc(b + h*2)/2; // outer tube radius, with compensation
  ih = sqrt(pow(rh,2)-pow(d/2,2)); // inner hole depth
  oh = rh-ih; // outer hole height
  di = d+tan(a)*2*ih; // inner hole diameter
  do = d+tan(s)*2*oh; // outer hole diameter
  sqx = sq*d; // square part
  fn = fns((d+w)/2); // segment resolution
  // position/scale/rotate
  slide(z) pivot(r) ovalize(d, w) squarify(sqx) {
    // angled wall
    cylinder(d1=di-sqx, d2=d-sqx, h=ih, $fn=fn);
    // shoulder cut
    slide(ih) cylinder(d1=d-sqx, d2=do-sqx, h=oh, $fn=fn);
  }
}
