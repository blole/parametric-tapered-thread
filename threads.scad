// Parametric tapering threads by blole
//   forked from
// ISO screw thread modules by RevK @TheRealRevK
// https://www.thingiverse.com/thing:2158656

/* [component type] */

type = "double collet";//[single collet,double collet]
include_collet = true;
include_nut1 = true;
include_nut2 = true;
printing = false;

/* [nut options] */
//Distance between flats for the hex nut
nut1_outer_diameter = 13;//[3,3.2,4,5,6,6,7,8,10,11,13,17,19,22,24,27,30,32,36,41,46,50,55]
nut2_outer_diameter = 27;//[3,3.2,4,5,6,6,7,8,10,11,13,17,19,22,24,27,30,32,36,41,46,50,55]
nut1_height = 6;
nut2_height = 12;
nut_type = "hex";//[hex,textured socket]

// Tolerance - expand nut internal thread by
nut_tolerance=0.2;

/* [collet options] */
cutouts1=3;
cutout_w1=1.5;
cutout_depth1=10;
inner_d1=5.2;

d1=13.5;
length1=12;
p1=1.5;
taper1 = 8/45;
top_angle1 = 30;
bottom_angle1 = 30;
flats = .2;
center_l = 4;

/* [bottom collet options] */
cutouts2=7;
cutout_w2=.5;
cutout_depth2=16;
inner_d2=2;
d2=20;
length2=20;
p2=2.5;
taper2 = 1/3;
top_angle2 = 45;
bottom_angle2 = 30;

$fn=48;
epsilon=0.01;

profile1     = thread_profile(p1, taper1, bottom_angle1, top_angle1, inner_flat=0, outer_flat=flats);
nut1_profile = thread_profile(p1, taper1, bottom_angle1, top_angle1, inner_flat=flats, outer_flat=0);
profile2     = thread_profile(p2, taper2, bottom_angle2, top_angle2, inner_flat=0, outer_flat=flats);
nut2_profile = thread_profile(p2, taper2, bottom_angle2, top_angle2, inner_flat=flats, outer_flat=0);

nut1_offset = floor((length1-nut1_height)/2/p1)*p1;
nut2_offset = floor((length2-nut2_height)/2/p2)*p2;
nut1_safe_distance = (nut1_outer_diameter+max(d1,d2))/2+1;
nut2_safe_distance = (nut2_outer_diameter+max(d1,d2))/2+1;

intersection() {
  union() {
    if (type=="double collet") {
      if (printing) {
        if (include_collet)
          double_collet();
        if (include_nut1)
          translate([nut1_safe_distance,0,0])
            nut1();
        if (include_nut2)
          translate([-nut2_safe_distance,0,0])
            nut2();
      }
      else {
        double_collet();
        translate([0,0,length2+center_l+nut1_offset-flats/2])
          nut1();
        translate([0,0,length2-nut2_height-nut2_offset+flats/2])
          nut2();
      }
    }
    
    if (type=="single collet") {
      if (printing) {
        if (include_collet)
          single_collet();
        if (include_nut1)
          translate([nut1_safe_distance,0,0])
            nut1();
      }
      else {
        single_collet();
        translate([0,0,center_l+nut1_offset-flats/2])
          nut1();
      }
    }
  }
  
  if (!printing) {
    translate([-1e3,0,-1e3])
      cube([2e3,2e3,2e3]);
  }
}

module nut1() {
  eliminate_outer_flat = flats/(tan(top_angle1)+tan(bottom_angle1));
  nut1_d = (radius(profile1, d1, nut1_offset)+eliminate_outer_flat)*2+nut_tolerance;
  nut(nut1_profile, nut1_d, nut1_outer_diameter, nut1_height);
}

module nut2() {
  translate([0,0,nut2_height]) rotate([180,0,0]) {
    eliminate_outer_flat = flats/(tan(top_angle2)+tan(bottom_angle2));
    nut2_d = (radius(profile2, d2, nut2_offset)+eliminate_outer_flat)*2+nut_tolerance;
    nut(nut2_profile, nut2_d, nut2_outer_diameter, nut2_height);
  }
}

module single_collet() {
  center_r = smallest_radius(profile1, d1, 0);
  
  difference() {
    union() {
      cylinder(r=center_r,h=center_l);
      translate([0,0,center_l])
        thread(profile1, m=d1, l=length1);
    }
    translate([0,0,center_l+length1]) mirror([0,0,1])
      collet_cutouts(cutouts1, cutout_w1, cutout_depth1);
    translate([0,0,-epsilon])
      cylinder(d=inner_d1,h=center_l+length1+epsilon*2);
  }
}

module double_collet() {
  center_r1 = smallest_radius(profile1, d1, 0);
  center_r2 = smallest_radius(profile2, d2, 0);
  
  difference() {
    union() {
      translate([0,0,length2])
        cylinder(r1=center_r2, r2=center_r1,h=center_l);
      translate([0,0,length2+center_l])
        thread(profile1, m=d1, l=length1);
      translate([0,0,length2]) rotate([180,0,0])
        thread(profile2, m=d2, l=length2);
      
    }
    translate([0,0,center_l+length1+length2]) mirror([0,0,1])
      collet_cutouts(cutouts1, cutout_w1, cutout_depth1);
    collet_cutouts(cutouts2, cutout_w2, cutout_depth2);
    
    inner_diff = abs(inner_d1-inner_d2);
    translate([0,0,-epsilon])
      cylinder(d=inner_d2,h=length2-inner_diff/2+center_l/2+epsilon);
    translate([0,0,length2-inner_diff/2+center_l/2-epsilon])
      cylinder(d1=inner_d2,d2=inner_d1,h=inner_diff+epsilon*2);
    translate([0,0,length2+inner_diff/2+center_l/2])
      cylinder(d=inner_d1,h=length1-inner_diff/2+center_l/2+epsilon*2);
  }
  
}

module collet_cutouts(cutouts,cutout_w,cutout_depth) {
  translate([0,0,-epsilon])
    if (cutouts>0)
      for (r=[0:360/cutouts:360])
        rotate([0,0,r])
          translate([-cutout_w/2,0,0])
            cube([cutout_w,1e3,cutout_depth+epsilon]);
}

/* Returns 5 points (x,y) detailing the repeating pattern of the thread
   
           __ p4
        /        }
       /         } top_slope_height
      /          }   (top_angle)
     / __ p3     }
    |          }
    |          } inner_flat
    |  __ p2   }
     \          } bottom_slope_height
      \  __ p1  }   (bottom_angle)
       |         }
       |         } outer_flat
       | __ p0   }
*/
function thread_profile(p,taper,bottom_angle,top_angle,inner_flat,outer_flat) = 
  let(taper_per_turn = taper*p)
  let(top_plus_bottom_slope_height = p - inner_flat - outer_flat - taper_per_turn*tan(top_angle))
  let(inner_radius_inset = top_plus_bottom_slope_height / (tan(bottom_angle)+tan(top_angle)))
  let(bottom_slope_height = inner_radius_inset*tan(bottom_angle))
  [
    [-inner_radius_inset,         0],
    [-inner_radius_inset,         inner_flat],
    [0,                           inner_flat + bottom_slope_height],
    [0,                           inner_flat + bottom_slope_height + outer_flat],
    [-inner_radius_inset-p*taper, p],
  ];

function p(profile) =      (profile[len(profile)-1] - profile[0])[1];
function taper(profile) = -(profile[len(profile)-1] - profile[0])[0]/p(profile);
function top_angle(profile) =    let(xy = profile[4] - profile[3]) atan2(xy[1], -xy[0]);
function bottom_angle(profile) = let(xy = profile[2] - profile[1]) atan2(xy[1],  xy[0]);
function radius(profile, m, height) = m/2 - height*taper(profile);
function biggest_radius(profile, m, height) = m/2 - (height+profile[3][1])*taper(profile);
function biggest_radius_underside(profile, m, height) =
    biggest_radius(profile, m, height+profile[3][1]-profile[2][1]);
function smallest_radius(profile, m, height) =
    biggest_radius(profile, m, height+profile[3][1]-profile[1][1])+profile[0][0];

module thread(
    profile,
    m=20,    // M size, mm, (outer diameter)
    p=0,  // Pitch, mm (0 for standard coarse pitch)
    l=50,   // length
    cap=1,  // capped ends. If uncapped, length is half a turn more top and bottom
)
{
  p = p(profile);
  
  fn=round($fn?$fn:36); // number of points per turn
  fa=360/fn; // angle of each point
  n=ceil(fn*l/p) + fn*(cap?3:1); // total number of points
  function r_at(i) =  biggest_radius(profile, m, i*p/fn - (cap?p:0)); //radius at index
  p1=[for(i=[0:1:n-1]) concat([cos(i*fa),sin(i*fa)]*(r_at(i)+profile[0][0]), i*p/fn+profile[0][1])];
  p2=[for(i=[0:1:n-1]) concat([cos(i*fa),sin(i*fa)]*(r_at(i)+profile[1][0]), i*p/fn+profile[1][1])];
  p3=[for(i=[0:1:n-1]) concat([cos(i*fa),sin(i*fa)]*(r_at(i)+profile[2][0]), i*p/fn+profile[2][1])];
  p4=[for(i=[0:1:n-1]) concat([cos(i*fa),sin(i*fa)]*(r_at(i)+profile[3][0]), i*p/fn+profile[3][1])];
  p5=[[0,0,p/2],[0,0,n*p/fn-p/2]];
  
  t1=[for(i=[0:1:fn-1]) [n*4,i,i+1]];
  t2=[[4*n,   n,   0],
      [4*n, 2*n,   n],
      [4*n, 3*n, 2*n],
      [4*n, fn,  3*n]];
  
  t3=[for(i=[0:1:n-2-fn])  [i,     i+n,     i+1]];
  t4=[for(i=[0:1:n-2-fn])  [i+n,   i+n+1,   i+1]];
  t5=[for(i=[0:1:n-2-fn])  [i+n,   i+2*n,   i+n+1]];
  t6=[for(i=[0:1:n-2-fn])  [i+2*n, i+2*n+1, i+n+1]];
  t7=[for(i=[0:1:n-2-fn])  [i+2*n, i+3*n,   i+2*n+1]];
  t8=[for(i=[0:1:n-2-fn])  [i+3*n, i+3*n+1, i+2*n+1]];
  t9=[for(i=[0:1:n-2-fn])  [i+3*n, i+fn,    i+3*n+1]];
  t10=[for(i=[0:1:n-2-fn]) [i+fn,  i+fn+1,  i+3*n+1]];
  
  t11=[for(i=[0:1:fn-1])[4*n+1, n-i-1, n-i-2]];
  t12=[[4*n+1,   n-fn-1, 2*n-fn-1],
       [4*n+1, 2*n-fn-1, 3*n-fn-1],
       [4*n+1, 3*n-fn-1, 4*n-fn-1],
       [4*n+1, 4*n-fn-1,   n-1]];
 
  intersection()
  {
    translate([0,0,-p/2-(cap?p:0)])
      polyhedron(points=concat(p1,p2,p3,p4,p5),
          faces=concat(t1,t2,t3,t4,t5,t6,t7,t8,t9,t10,t11,t12),
          convexity=l/p+5);
    
    if (cap) hull() {
      ri0 = smallest_radius(profile,m,0);
      riL = smallest_radius(profile,m,l);
      cylinder(r1=ri0,r2=ri0+p/tan(bottom_angle(profile)),h=p);
      translate([0,0,l]) rotate([0,180,0])
        cylinder(r1=riL,r2=riL+p/tan(top_angle(profile)),h=p);
    }
  }
}

module nut(profile, m, d, w=0)
{
  w=(w?w:m/2); // How thick to make the nut
  p = p(profile);
  taper=taper(profile);
  tr = biggest_radius(profile,m,w)+1;
  br = biggest_radius(profile,m,0)+1;
  difference()
  {
    hex_head(d=d,w=w);
    translate([0,0,-p])
    thread(profile, m=m+2*p*taper, l=w+2*p);
    //translate([0,0,-1])cylinder(r1=r+1,r2=r-5*h/8,h=1+5*h/8*tan(30));
    //translate([0,0,w-5*h/8*tan(30)])cylinder(r2=r+1,r1=r-5*h/8,h=1+5*h/8*tan(30));
    translate([0,0,w+tan(bottom_angle(profile))]) mirror([0,0,1])
      cylinder(r1=tr,r2=0,h=tr*tan(bottom_angle(profile)));
    translate([0,0,-tan(top_angle(profile))])
      cylinder(r1=br,r2=0,h=br*tan(top_angle(profile)));
  }
}

module hex_head(d=30,w=0)
{ // Make a hex head centred 0,0 with height h and wrench size/diameter d
  intersection()
  {
    w=(w?w:d/3);
    r=d/2;
    m=sqrt(r*r+r*r*tan(30)*tan(30))-r;
    rotate([0,0,90])
      cylinder(r=r+m,h=w,$fn=6);
    union()
    {
      cylinder(r1=r,r2=r+m,h=m);
      translate([0,0,m])cylinder(r=r+m,h=w-m*2);
      translate([0,0,w-m])cylinder(r1=r+m,r2=r,h=m);
    }
  }
}
