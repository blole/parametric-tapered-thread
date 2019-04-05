// ISO screw thread modules by RevK @TheRealRevK
// https://en.wikipedia.org/wiki/ISO_metric_screw_thread
// Usable as a library - provides standard nut and both as well as arbitrary thread sections

/* [ Global ] */

// Length of bolt
l=50;

// Size
m=20; // [1.4,1.6,2,2.5,3,4,5,6,7,8,10,12,14,16,18,20,22,24,27,30,33,36]

// Clearance for printer tollerance for nut
t=0.2;

// Steps
$fn=48;



inner_d=5.4;
top_d=9.7;
bottom_d=13;
length=11.75;
center_l=2;
angle=45;
p=0;


p=(p?p:iso_pitch_coarse(m));
epsilon=0.01;


//collet(top_d=top_d, bottom_d=bottom_d,l=length,p=3,leadin=2,leadout=2,cutouts=3);
taper = -(top_d - bottom_d)/length/2;
function r(height) = bottom_d/2 - height*taper;
function ri(height) = r(height+inner_flat) - inner_radius_inset;

echo(taper);
collet(bottom_d, length, p=p, taper=taper, inner_d=inner_d, cutouts=3);
rotate([0,180,0])
  cylinder(d=ri(0),h=center_l);

module collet(m, l, p=0, taper=0, inner_d=0, cutouts=0, cutout_w=1, leadin=0, leadout=0) {
  difference() {
    iso_thread(m=m,l=l,p=p,taper=taper);
  
    //cylinder_chamfer(m,leadout);
    //translate([0,0,l]) rotate([0,180,0])
    //  cylinder_chamfer(m,leadin);
  
    translate([0,0,-epsilon])
      cylinder(d=inner_d,h=l+epsilon*2);
    
    if (cutouts>0)
      for (r=[0:360/cutouts:360])
        rotate([0,0,r])
          translate([-cutout_w/2,0,-epsilon])
            cube([cutout_w,m/2+1,l+epsilon*2]);
    }
}

// Examples
//union(){iso_bolt(m=20,l=50);translate([40,0,0])iso_nut(m=20);}
//union(){iso_bolt(m=10,l=30);translate([25,0,0])iso_nut(m=10);}
//iso_thread(l=20,cap=0);
//iso_thread(l=5);
//iso_nut(m=20);
//union(){difference(){iso_bolt(m=20,l=50);linear_extrude(height=0.4)scale(1.4)import("/Users/adrian/Documents/3D/DXF/aac.dxf");};translate([40,0,0])iso_nut(m=20);}

function iso_hex_size(m)    // Return standard hex nut size for m value
=lookup(m,[
 [1.4,3],
 [1.6,3.2],
 [2,4],
 [2.5,5],
 [3,6],
 [3.5,6],
 [4,7],
 [5,8],
 [6,10],
 [7,11],
 [8,13],
 [10,17],
 [12,19],
 [14,22],
 [16,24],
 [18,27],
 [20,30],
 [22,32],
 [24,36],
 [27,41],
 [30,46],
 [33,50],
 [36,55],
 ]);
 
 
 function iso_pitch_coarse(m)   // Return standard coarse pitch for m value
=lookup(m,[
[1,0.25],
[1.2,0.25],
[1.4,0.3],
[1.6,0.35],
[1.8,0.35],
[2,0.4],
[2.5,0.45],
[3,0.5],
[3.5,0.6],
[4,0.7],
[5,0.8],
[6,1],
[7,1],
[8,1.25],
[10,1.5],
[12,1.75],
[14,2],
[16,2],
[18,2.5],
[20,2.5],
[22,2.5],
[24,3],
[27,3],
[30,3.5],
[33,3.5],
[36,4],
[39,4],
[42,4.5],
[48,5],
[52,5],
[56,5.5],
[60,5.5],
[62,6]
  ]);

module hex_head(d=30,w=0)
{ // Make a hex head centred 0,0 with height h and wrench size/diameter d
    intersection()
    {
        w=(w?w:d/3);
        r=d/2;
        m=sqrt(r*r+r*r*tan(30)*tan(30))-r;
        cylinder(r=r+m,h=w,$fn=6);
        union()
        {
            cylinder(r1=r,r2=r+m,h=m);
            translate([0,0,m])cylinder(r=r+m,h=w-m*2);
            translate([0,0,w-m])cylinder(r1=r+m,r2=r,h=m);
        }
    }
}

module iso_thread(  // Generate ISO / UTS thread, centred 0,0,
    m=20,    // M size, mm, (outer diameter)
    p=0,  // Pitch, mm (0 for standard coarse pitch)
    l=50,   // length
    taper=.0,
    bottom_angle=30,
    top_angle=30,
    inner_flat=1/4,
    outer_flat=1/8,
    cap=1,  // capped ends. If uncapped, length is half a turn more top and bottom
)
{
    p=(p?p:iso_pitch_coarse(m));
    inner_flat = inner_flat*p;
    outer_flat = outer_flat*p;
  
    /*
  
            /        }
           /         } top_slope_height (top_angle)
          /          }
         / __ o3     }
        |          }
        |          } inner_flat
        |  __ o2   }
         \          } bottom_slope_height (bottom_angle)
          \  __ o1  }     
           |         }
           |         } outer_flat
           |         }
    
    */
    taper_per_turn = taper*p;
    top_plus_bottom_slope_height = p - inner_flat - outer_flat - taper_per_turn*tan(top_angle);
    inner_radius_inset = top_plus_bottom_slope_height / (tan(bottom_angle)+tan(top_angle));
    bottom_slope_height = inner_radius_inset*tan(bottom_angle);
    top_slope_height = top_plus_bottom_slope_height - bottom_slope_height;
    o1=inner_flat;
    o2=inner_flat + bottom_slope_height;
    o3=inner_flat + bottom_slope_height + outer_flat;
    
    fn=round($fn?$fn:36); // number of points per turn
    fa=360/fn; // angle of each point
    n=ceil(fn*l/p) + fn*(cap?3:1); // total number of points
    function r(height) = m/2 - height*taper;
    function ri(height) = r(height+inner_flat) - inner_radius_inset;
    function r_at(i) =  r(i*p/fn - (cap?p:0)); //radius at index
    function ri_at(i) = r_at(i) - inner_radius_inset;
    p1=[for(i=[0:1:n-1]) [cos(i*fa)*ri_at(i), sin(i*fa)*ri_at(i), i*p/fn]];
    p2=[for(i=[0:1:n-1]) [cos(i*fa)*ri_at(i), sin(i*fa)*ri_at(i), i*p/fn+o1]];
    p3=[for(i=[0:1:n-1]) [cos(i*fa)*r_at(i),  sin(i*fa)*r_at(i),  i*p/fn+o2]];
    p4=[for(i=[0:1:n-1]) [cos(i*fa)*r_at(i),  sin(i*fa)*r_at(i),  i*p/fn+o3]];
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
          cylinder(r1=ri(0),r2=ri(0)+p/tan(bottom_angle),h=p);
          translate([0,0,l]) rotate([0,180,0])
            cylinder(r1=ri(l),r2=ri(l)+p/tan(top_angle),h=p);
        }
    }
}

module iso_bolt(m=20,w=0,l=50,p=0)
{
    hex_head(d=iso_hex_size(m),w=w);
    iso_thread(m=m,l=l,p=p);
}

module iso_nut(m=20,w=0,p=0,t=0.2)
{
    w=(w?w:m/2); // How thick to make the nut
    p=(p?p:iso_pitch_coarse(m)); // standard pitch
    h=sqrt(3)/2*p;  // height of thread
    r=m/2; // radius
    difference()
    {
        hex_head(d=iso_hex_size(m),w=w);
        translate([0,0,-p/2])iso_thread(m=m,p=p,l=w+p,t=t,cap=0);
        translate([0,0,-1])cylinder(r1=r+t+1,r2=r-5*h/8+t,h=1+5*h/8*tan(30));
        translate([0,0,w-5*h/8*tan(30)])cylinder(r2=r+t+1,r1=r-5*h/8+t,h=1+5*h/8*tan(30));
    }
}

module cylinder_chamfer(d, h, angle=45) difference() {
  translate([0,0,-epsilon])
    cylinder(r=d/2+1, h=h+epsilon);
  translate([0,0,h+epsilon]) rotate([0,180,0])
    cylinder (r2=0, r1=d/2+epsilon*tan(angle), h=(d/2+epsilon)*tan(angle));
}
