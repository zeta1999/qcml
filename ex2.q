\l /Users/nick/q/funq/plot.q
\l /Users/nick/q/funq/ml.q
\l /Users/nick/q/qml/src/qml.q
\l /Users/nick/q/funq/qmlmm.q

\
\c 50 100
.plot.plt .ml.sigmoid .1*-50+til 100 / plot sigmoid function
\cd /Users/nick/Downloads/machine-learning-ex2/ex2
data:("FFF";",")0:`:ex2data1.txt
.plot.plt data
X:2#data
Y:-1#data
THETA:(1;1+count X)#0f
.ml.logcost[X;Y;THETA]        / logistic regression cost
.ml.loggrad[X;Y;THETA]        / logistic regression gradient

/ rk:runge–kutta, slp: success linear programming
opts:`quiet`rk`iter,7000
/ find function minimum
THETA:(1;1+count X)#0f
.qml.minx[opts;.ml.logcost[X;Y];THETA]
/ use gradient to improve efficiency
.qml.minx[opts;.ml.logcostgradf[X;Y];THETA]

/ compare plots
THETA:.qml.minx[opts;.ml.logcost[X;Y];THETA]
.plot.plt data
.plot.plt X,.ml.lpredict[X] THETA

