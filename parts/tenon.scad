/*
 * Tenon & mortise using AS568-019 o-rings
 */
include <tools.scad>;

A=23.52; // mortise inner bore
C=23.42; // piston outer diameter
F=20.68; // gland outer diameter
CS=1.78; // o-ring minor diameter
X=23.9;  // o-ring diameter (unstretched)
B=19.0;  // flute bore diameter
O=26.0;  // flute outer diameter

module mortise(z=0, l=26) {
  lz=(A-B)/2;
  slide(z) difference() {
    shell(b=O, l=l);
    // bore
    bore(b=A, l=l-lz);
    // bevel to flute bore
    bore(z=l-lz, b=A, b2=B, l=lz);
    // entrance lip
    bore(b=X, b2=A, l=(X-A)/2);
  }
}

module gland019(z=0) {
  lz=(C-F)/2;
  slide(z) difference() {
    // piston
    bore(b=C, l=CS+lz);
    // flat
    bore(b=F, l=CS);
    // bevel to piston
    bore(z=CS, b=F, b2=C, l=lz);
  }
}

module tenon(z=0, l=26) {
  slide(z) difference() {
    lz=(C-B)/2;
    union() {
      shell(b=C, l=l-lz);
      shell(z=l-lz, b=C, b2=B, l=lz);
    }
    bore(b=B, l=l);
    gland019(z=l-6);
    gland019(z=6);
  }
}

translate([-15,0,0]) tenon();
translate([15,0,0]) mortise();