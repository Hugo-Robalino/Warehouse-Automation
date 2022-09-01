-*- asp -*-

#show.
#show occurs(object(robot,RobotID),action(move,D),T) : occurs_m(robot(RobotID),action(move((direction(D),node(_)))),T).
#show occurs(object(robot,RobotID),action(pickup,()),T) : occurs_p(robot(RobotID),action(pickup(_)),T).
#show occurs(object(robot,RobotID),action(putdown,()),T) : occurs_p(robot(RobotID),action(putdown(_)),T).
#show occurs(object(robot,RobotID),action(deliver,(OrderID,ProductID)),T) : occurs_p(robot(RobotID),action(deliver((order(OrderID),product(ProductID),_,_))),T).
