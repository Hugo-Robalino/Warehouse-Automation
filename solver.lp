-*- asp -*-

%REPRESENTATION (of objects)
robot(R) :- init(object(robot,R),_). 
shelf(S) :- init(object(shelf,S),_).
node(C)  :- init(object(node,_),value(at,C)).
product(X) :- init(object(product,X),_).
station(P) :- init(object(pickingStation,P),_).
order(O) :- init(object(order,O),_).
carries(0;shelf(S)) :- init(object(shelf,S),_). 

%GOAL
:- link(V), not occurs_p(_,action(deliver(V)),_).

%positions and orders
position(robot(R),node(C),carries(0),0) :- init(object(robot,R),value(at,C)).
position(shelf(S),node(C),0) :- init(object(shelf,S),value(at,C)). 
position(station(P),node(C))   :- init(object(pickingStation,P), value(at,C)).
link((order(O),product(X),shelf(S),station(P))) :- 
    init(object(order,O),value(line,(X,_))), 
    init(object(order,O),value(pickingStation,P)),
    init(object(product,X),value(on,(S,_))).

%helpful auxiliaryt atoms
isRobot(robot(R)) :- robot(R). %fluent
isShelf(shelf(S)) :- shelf(S). 
isAction_m(action(move((D,C)))) :- action(move((D,C))). %diff act atoms
isAction_p(action(pickup(S))) :- action(pickup(S)). %diff act atoms
isAction_p(action(putdown(S))) :- action(putdown(S)). %diff act atoms
isAction_p(action(deliver(V))) :- link(V). %diff act atoms
isProduct(product(X)) :- product(X).
isStation(station(P)) :- station(P).
isOrder(order(O)) :- order(O).
isNode(node(C)) :- node(C).
isDir(direction(D)) :- direction(D).
isCarry(carries(B)) :- carries(B).

%actions
direction((X,Y)) :- X=-1..1, Y=-1..1, |X+Y|=1.
seq(direction((X',Y')),node((X,Y)),node((X+X',Y+Y'))) :- direction((X',Y')), node((X,Y)), node((X+X',Y+Y')). 
action(move((D,C))) :- isDir(D), isNode(C), isNode(C'), seq(D,C,C'). 
action(pickup(S)) :- isShelf(S).
action(putdown(S)) :- isShelf(S).
action(deliver(V)) :- link(V).

%preconditions and postconditions
prec(action(move((D,C))),R,C) :- action(move((D,C))), isRobot(R), isNode(C). %R must be in C
post(action(move((D,C))),R,C') :- action(move((D,C))), isRobot(R), isNode(C), isNode(C'), seq(D,C,C').
prec(action(pickup(S)),R,B) :- action(pickup(S)), isRobot(R), B=carries(0). %R mustn't carry S
post(action(pickup(S)),R,B) :- action(pickup(S)), isRobot(R), B=carries(S). %R must carry S
prec(action(putdown(S)),R,B) :- action(putdown(S)), isRobot(R), B=carries(S). 
post(action(putdown(S)),R,B) :- action(putdown(S)), isRobot(R), B=carries(0).
prec(action(deliver((O,X,S,P))),R,B) :- action(deliver((O,X,S,P))), isRobot(R), B=carries(S).
post(action(deliver((O,X,S,P))),R,B) :- action(deliver((O,X,S,P))), isRobot(R), B=carries(S).

%action deliver at Picking Station
timedLink(R,(O,X,S,P),C,T) :- link((O,X,S,P)), position(R,C,_,T),position(S,C,T), position(P,C).
:- occurs_p(R,action(deliver((O,X,S,P))),T), position(P,C), not timedLink(R,(O,X,S,P),C,T).
T1=T2 :- occurs_p(_,action(deliver(V)),T1), occurs_p(_,action(deliver(V)),T2).

%Shelf movement and its auxiliary atoms
C=C' :- position(S,C,T-1), position(S,C',T), occurs_p(R,action(pickup(S)),T), not position(R,C,_,T-1).
{on(S,R,T)} :- occurs_p(R,action(putdown(S)),T).
:- on(S,R,T), occurs_p(R,action(putdown(S)),T), not occurs_m(R,_,T).
on(S,R,T) :- position(R,_,carries(S),T), S!=0.
position(S,C,T) :- position(S,C,T-1), not on(S,_,T), T=1..h.
position(S,C,T) :- position(R,C,_,T), on(S,R,T).

%only one R per node / one S per R / no R collision / only one S per node
R1=R2 :- position(R1,C,_,T), position(R2,C,_,T).
R1=R2 :- position(R1,_,B,T), position(R2,_,B,T), B!=carries(0).
R1=R2:- position(R1,C,_,T), position(R2,C',_,T), position(R1,C',_,T+1), position(R2,C,_,T+1).
S1=S2 :- position(S1,C,T), position(S2,C,T).

%main part I (same as E_step, E-relaxed and for_all_step)
{position(R,C,B,T) : isNode(C), isCarry(B)} = 1 :- isRobot(R), T=1..h. 
{occurs_m(R,A,T)} :- isRobot(R), isAction_m(A), T=1..h.
{occurs_p(R,A,T)} :- isRobot(R), isAction_p(A), T=1..h. 
:- occurs_m(R,A,T), post(A,R,C), not position(R,C,_,T).
:- occurs_p(R,A,T), post(A,R,B), not position(R,_,B,T). 
T=0:- position(R,C,_,T), not position(R,C,_,T-1), not occurs_m(R,A,T): post(A,R,C).
T=0:- position(R,_,B,T), not position(R,_,B,T-1), not occurs_p(R,A,T): post(A,R,B).

%main par II (for_all)
:- occurs_m(R,A,T), prec(A,R,C), not position(R,C,_,T-1). 
A1=A2:- occurs_m(R,A1,T), occurs_m(R,A2,T).
:- occurs_p(R,A,T), prec(A,R,B), not position(R,_,B,T-1). 
A1=A2:- occurs_p(R,A1,T), occurs_p(R,A2,T).

#show occurs_m/3.
#show occurs_p/3.
#show position/2.
#show position/3.
