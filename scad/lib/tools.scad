/*
 * Various flute-making tools
 */
include <consts.scad>;

// used to calculate number of polygon segments ($fn) multiple of 4
function fn(b) = ceil(PI*b/NOZZLE_DIAMETER/2)*4;

// used to calculate diameter of inscribed polygon
function ins(b) = sqrt(pow(NOZZLE_DIAMETER,2) + 4*pow(1/cos(180/$fn)*b/2,2));

// translate +z axis
module slide(z=LAYER_HEIGHT) {
  translate([0,0,z]) children();
}

// rotate x by r, y by 90 and z by -90 (for holes)
module pivot(r=0) {
  rotate([r,90,-90]) children();
}

// translate z, then cylinder d1=b, d2=b2|b, h=l
module shell(z=0, b=NOZZLE_DIAMETER, b2, l=LAYER_HEIGHT) {
  b2 = (b2==undef) ? b : b2;
  maxfn = fn(max(b, b2)); // adaptive resolution
  slide(z) cylinder(d1=b, d2=b2, h=l, $fn=maxfn);
}

// like shell, but inscribed polygon and micron z variance
module bore(z=0, b=NOZZLE_DIAMETER, b2, l=LAYER_HEIGHT) {
  b2 = (b2==undef) ? b : b2;
  ex = NOZZLE_DIAMETER;
  maxfn = fn(max(b, b2)+ex); // adaptive resolution
  slide(z-0.001) cylinder(d1=ins(b+ex, $fn=maxfn), d2=ins(b2+ex, $fn=maxfn), h=l+0.002, $fn=maxfn);
}

// tube: bore with a shell wall
module tube(z=0, b=NOZZLE_DIAMETER, b2, l=LAYER_HEIGHT, h=NOZZLE_DIAMETER, h2) {
  b2 = (b2==undef) ? b : b2;
  h2 = (h2==undef) ? h : h2;
  difference() {
    shell(z=z, b=b+2*h, b2=b2+2*h2, l=l);
    bore(z=z, b=b, b2=b2, l=l);
  }
}

// tone or embouchure hole
// (b)ore (h)eight (d)iameter (w)idth (r)otate° w(a)ll°
// (s)houlder° (sq)areness
module hole(z=0, b, h, d, w, r=0, a=0, s=0, sq=0) {
  dx = d + NOZZLE_DIAMETER;
  wx = (w==undef) ? dx : (w + NOZZLE_DIAMETER);
  sqx = sq*dx; // square part
  rh = b/2 + h; // bore radius + height
  ih = sqrt(pow(rh,2)-pow(dx/2,2)); // inner hole depth
  oh = rh-ih; // outer hole height
  di = dx+tan(a)*2*ih; // inner hole diameter
  do = dx+tan(s)*2*oh; // outer hole diameter
  ofn = fn(max(dx-sqx, do-sqx)); // outer segments
  ifn = fn(max(dx-sqx, di-sqx)); // inner segments
  // position/scale/rotate
  slide(z) scale([1,1,wx/dx]) pivot(-r)
    if (sqx >= 0.001) {
      // squarish hole
      minkowski() {
        cube([sqx,sqx,0.001], center=true);
        union() {
          // shoulder cut
          shell(z=ih, b=ins(dx-sqx, $fn=ofn), b2=ins(do-sqx, $fn=ofn), l=oh);
          // angled wall
          shell(b=ins(di-sqx, $fn=ifn), b2=ins(dx-sqx, $fn=ifn), l=ih);
        }
      }
    } else {
      // round hole
      union() {
        // shoulder cut
        shell(z=ih, b=ins(dx, $fn=ofn), b2=ins(do, $fn=ofn), l=oh);
        // angled wall
        shell(b=ins(di, $fn=ifn), b2=ins(dx, $fn=ifn), l=ih+0.001);
      }
    }
}
