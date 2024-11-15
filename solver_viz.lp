%New occur atoms
occur(R,A,T) :- occurs_m(R,A,T).
occur(R,A,T) :- occurs_p(R,A,T).

%Cases
case_mp(R,action(move((D,C1))),T) :- occur(R,action(move((D,C1))),T), occur(R,action(pickup(S)),T), position(S,C2,T-1), C1!=C2.
case_mp(R,action(move((D,C1))),T) :- occur(R,action(move((D,C1))),T), occur(R,action(putdown(S)),T), position(S,C2,T), C1!=C2.
case_mp(R,action(move((D,C1))),T) :- occur(R,action(move((D,C1))),T), occur(R,action(deliver((_,_,_,P))),T), position(P,C2), C1!=C2.
case_pm(R,action(pickup(S)),T) :- occur(R,action(move((D,C1))),T), occur(R,action(pickup(S)),T), position(S,C2,T-1), C1=C2.
case_pm(R,action(putdown(S)),T) :- occur(R,action(move((D,C1))),T), occur(R,action(putdown(S)),T), position(S,C2,T), C1=C2.
case_pm(R,action(deliver((O,X,S,P))),T) :- occur(R,action(move((D,C1))),T), occur(R,action(deliver((O,X,S,P))),T), position(P,C2), C1=C2.

%useful atoms
step0(S0) :- S0 = #min{T : occur(_,_,T)}. % # of first time step
parallel(R,T) :- occur(R,A1,T), occur(R,A2,T), A1!=A2. %time steps where parallel actions take place

%parallel steps organized
occur(R,A,T,i) :- occur(R,A,T), case_mp(R,A,T).
occur(R,A,T,i) :- occur(R,A,T), case_pm(R,A,T).
occur(R,A,T,i) :- occur(R,A,T), not parallel(R,T).
occur(R,A1,T,ii) :- occur(R,A1,T), occur(R,A2,T,i), A1!=A2.

%chain
n((S0,i),0) :- occur(_,_,S0,i), step0(S0).
n((T,ii),(T,i)) :- occur(_,_,T,ii), occur(_,_,T,i).
n((T,i),(T-1,i)) :- occur(_,_,T,i), occur(_,_,T-1,i), not occur(_,_,T-1,ii).
n((T,i),(T-1,ii)) :- occur(_,_,T,i), occur(_,_,T-1,ii).
n((T,i),(T-2,i)) :- occur(_,_,T,i), occur(_,_,T-2,i), not occur(_,_,T-2,ii), not n((T,i),(T-1,_)).
n((T,i),(T-2,ii)) :- occur(_,_,T,i), occur(_,_,T-2,ii), not n((T,i),(T-1,_)).

%creating a chain order
nexus(M,(S0,i),1) :- n(M,(S0,i)), step0(S0).
nexus(N,M,T+1) :- nexus(M,_,T), n(N,M).

%pairing old A into new Time steps
pair((S0,i),S0) :- nexus(_,(S0,i),1), step0(S0).
pair((M,I),T+M-N+1) :- nexus((M,I),(N,II),_), pair((N,II),T).

%occurs atoms
occurs(R,A,NTS) :- occur(R,A,T,I), pair((T,I),NTS).

#show.
#show occurs(object(robot,RobotID),action(move,D),T) : occurs(robot(RobotID),action(move((direction(D),node(_)))),T).
#show occurs(object(robot,RobotID),action(pickup,()),T) : occurs(robot(RobotID),action(pickup(_)),T).
#show occurs(object(robot,RobotID),action(putdown,()),T) : occurs(robot(RobotID),action(putdown(_)),T).
#show occurs(object(robot,RobotID),action(deliver,(OrderID,ProductID)),T) : occurs(robot(RobotID),action(deliver((order(OrderID),product(ProductID),_,_))),T).