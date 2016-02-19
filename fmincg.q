RHO:.01 / a bunch of constants for line searches
SIG:.5  / RHO and SIG are the constants in the Wolfe-Powell conditions
INT:.1 / don't reevaluate within 0.1 of the limit of the current bracket
EXT:3f / extrapolate maximum 3 times the current bracket
MAX:20 / max 20 function evaluations per line search
RATIO:100 / maximum allowed slope ratio
REALMIN:2.2251e-308

wolfepowell:{[d;f;z]$[d[2]>d[1]*neg SIG;1b;f[2;0]>f[1;0]+d[1]*RHO*z[1]]}
polackribiere:{[df1;df2;s](s*((df2$df2)-df1$df2)%df1$df1)-df2}
quadfit:{[f2;f3;d2;d3;z3]z3-(.5*d3*z3*z3)%(f2-f3)+d3*z3}
cubicfit:{[f2;f3;d2;d3;z3]
 A:(6f*(f2-f3)%z3)+3f*d2+d3;
 B:(3f*f3-f2)-z3*d3+2f*d2;
 z2:(sqrt[(B*B)-A*d2*z3*z3]-B)%A; / numerical error possible - ok!
 z2}
cubicextrapolation:{[f2;f3;d2;d3;z3]
 A:(6f*(f2-f3)%z3)+3f*d2+d3;
 B:(3f*f3-f2)-z3*d3+2f*d2;
 z2:(z3*z3*neg d2)%(B+sqrt[(B*B)-A*d2*z3*z3]); / numerical error possible - ok!
 z2}

minimize:{[f;d;z;s;F;X]
 z[2]:$[f[2;0]>f[1;0];quadfit;cubicfit][f[2;0];f[3;0];d[2];d[3];z[3]];
 if[z[2] in 0n -0w 0w;z[2]:.5*z[3]]; / if we had a numerical problem then bisect
 z[2]:(z[3]*1f-INT)|z[2]&INT*z[3]; / don't accept too close to limits
 z[1]+:z[2];
 X+:z[2]*s;
 f[2]:F X;
 d[2]:f[2;1]$s;
 z[3]-:z[2];                / z3 is now relative to the location of z2
 (f;d;z;X)}

extrapolate:{[limit;f;d;z;s;F;X]
 z[2]:cubicextrapolation[f[2;0];f[3;0];d[2];d[3];z[3]];
 z[2]:$[$[z[2]<0;1b;z[2]=0w];$[limit<=.5;z[1]*EXT-1f;.5*limit-z[1]];
  $[limit>-.5;limit<z[2]+z[1];0b];.5*limit-z[1]; / extraplation beyond max? -> bisect
  $[limit<-.5;(z[1]*EXT)<z[2]+z[1];0b];z[1]*EXT-1f; / extraplation beyond limit -> set to limit
  z[2]<z[3]*neg INT;z[3]*neg INT;
  $[limit>-.5;z[2]<(limit-z[1])*1f-INT;0b];(limit-z[1])*1f-INT; / too clost to limit?
  z[2]];
 f[3]:f[2];d[3]:d[2];z[3]:neg z[2]; / set point 3 equal to point 2
 z[1]+:z[2];X+:z[2]*s;              / update current estimates
 f[2]:F X;
 d[2]:f[2;1]$s;
 (f;d;z;X)}

loop:{[n;i;f;d;z;s;F;X]
 i+:n>0;                        / count iterations?!
 X+:z[1]*s;                     / begin line search
 f[2]:F X;
 i+:n<0;                        / count epochs?!
 d[2]:f[2;1]$s;
 f[3]:f[1];d[3]:d[1];z[3]:neg z[1]; / initialize point 3 equal to point 1
 M:$[n>0;MAX;MAX&neg n-i];
 success:0b;limit:-1;           / initialize quantities
 BREAK:0b;
 while[not BREAK;
  while[$[M>0;wolfepowell[d;f;z];0b];
   limit:z[1];                  / tighten the bracket
   X:minimize[f;d;z;s;F;X];f:X 0;d:X 1;z:X 2;X@:3;
   M-:1;i+:n<0;                 / count epochs?!
   ];
  if[wolfepowell[d;f;z];BREAK:1b];        / this is a failure
  if[d[2]>SIG*d[1];success:1b;BREAK:1b]; / success
  if[M=0;BREAK:1b];                      / failure
  if[not BREAK;
   X:extrapolate[limit;f;d;z;s;F;X];f:X 0;d:X 1;z:X 2;X@:3;
   M-:1;i+:n<0;                / count epochs?!
   ];
  ];
 (success;i;f;d;z;X)}

onsuccess:{[i;f;d;z;s]
 f[1;0]:f[2;0];
 -1"Iteration ",string[i]," | Cost: ", string f[1;0];
 s:polackribiere[f[1;1];f[2;1];s]; / Polack-Ribiere direction
/ break;
 f[2 1;1]:f[1 2;1];                / swap derivatives
 d[2]:f[1;1]$s;
 if[d[2]>0;s:neg f[1;1];d[2]:s$neg s]; / new slope must be negative, otherwise use steepest direction
 z[1]*:RATIO&d[1]%d[2]-REALMIN;        / slope ratio but max RATIO
 d[1]:d[2];
 (f;d;z;s)}

fmincg:{[n;F;X]                 / n can default to 100
 i:0;                           / zero the run length counter
 ls_failed:0b;                  / no previous line search has failed
 fX:();
 f:4#enlist 2#0n;               / make room for f0, f1, f2 and f3
 z:4#0n;                        / make room for z0, z1, z2 and z3
 d:4#0n;                        / make room for d0, d1, d2 and d3
 f[1]:F X;                      / get function value and gradient
 s:neg f[1;1];                  / search direction is steepest
 d[1]:s$neg s;                  / this is the slope
 z[1]:(n:n,1)[1]%1f-d[1];       / initial step is red/(|s|+1)
 n@:0;                          / n is first element
 i+:n<0;                        / count epochs?!

 while[i<abs n;                 / while not finished
  X0:X;f[0]:f[1];               / make a copy of current values
  X:loop[n;i;f;d;z;s;F;X];success:X 0;i:X 1;f:X 2;d:X 3;z:X 4;X@:5;
  if[success;fX,:f[2;0];s:onsuccess[i;f;d;z;s];f:s 0;d:s 1;z:s 2;s@:3];
  if[not success;
   X:X0;f[1]:f[0];     / restore point from before failed line search
   if[$[ls_failed;1b;i>abs n];:(X;fX;i)]; / line search failed twice in a row or we ran out of time, so we give up
   f[2 1;1]:f[1 2;1];                           / swap derivatives
   z[1]:1f%1f-d[1]:s$neg s:neg f[1;1];         / try steepest
   ];
  ls_failed:not success;        / line search failure
  ];
 (X;fX;i)}