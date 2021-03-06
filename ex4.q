\l funq.q

-1 "using random values to check neural network gradient calculation";
hgolf:`h`g`o`l!`.ml.sigmoid`.ml.dsigmoid`.ml.sigmoid`.ml.logloss
rf:.ml.l2[.1]
.util.assert . .util.rnd[1e-6] .ml.checknngrad[1e-4;rf;3 5 3;hgolf]

-1 "loading data set";
X:(400#"F";",")0:`:ex4dataX.txt
y:first (1#"F";",")0:`:ex4datay.txt
THETA1:flip (401#"F";",") 0:`:ex4theta1.txt
THETA2:flip (26#"F";",") 0:`:ex4theta2.txt

-1 "using loaded THETA values to predict y";
.ml.nnpredict[hgolf;X] (THETA1;THETA2)
Y:.ml.diag[10#1f]@\:"i"$y-1
-1 "confirming logistic cost calculations with and without regularization";
n:400 25 10
rf:.ml.l2[1f]
theta:2 raze/ THETA:(THETA1;THETA2)
.util.assert[0.28762916516131876] .ml.nncost[();hgolf;Y;X] THETA
.util.assert[0.38376985909092381] .ml.nncost[rf;hgolf;Y;X] THETA
.util.assert[0.026047433852894011] sum 2 raze/ .ml.nngrad[();hgolf;Y;X] THETA
.util.assert[0.0099559365856808548] sum 2 raze/ .ml.nngrad[rf;hgolf;Y;X] THETA

Y:.ml.diag[last[n]#1f]@\:"i"$y-1
-1 "computing the sum of each gradient";
sum 2 raze/ .ml.nngrad[rf;hgolf;Y;X;THETA]

-1 "computing the cost and gradient of given THETA values";
.ml.nncostgrad[();n;hgolf;Y;X;theta]

-1 "initializing theta";
theta:2 raze/ .ml.glorotu'[1+-1_n;1_n];
-1 "optimizing THETA";
theta:first .fmincg.fmincg[50;.ml.nncostgrad[();n;hgolf;Y;X];theta]

-1 "using one vs all to predict y";
100*avg y=p:1+.ml.clfova .ml.nnpredict[hgolf;X] .ml.nncut[n] theta
-1 "visualize hidden features";
plt:value .util.plot[20;10;.util.c16;avg] .util.hmap 20 cut
-1 plt 1_first THETA1;

-1 "showing a few mistakes";
\c 100 200
w:-4?where not y=p:1f+.ml.clfova .ml.nnpredict[hgolf;X] .ml.nncut[n] theta
-1 (,'/) plt each  X@\:/:w;
show flip([]p;y)w

-1 "showing the confusion matrix";
show .util.cm[y;p]
