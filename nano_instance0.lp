%PRACTICE INSTANCE:- Grid and objects
#const n=13.

init(object(node,1),value(at,(1,1))).
init(object(node,2),value(at,(2,1))).
init(object(node,3),value(at,(3,1))).

init(object(robot,1),value(at,(1,1))).
init(object(shelf,1),value(at,(2,1))).
init(object(pickingStation,1),value(at,(3,1))).

init(object(product,1),value(on,(1,7))).
init(object(order,1),value(line,(1,4))).
init(object(order,1),value(pickingStation,1)).