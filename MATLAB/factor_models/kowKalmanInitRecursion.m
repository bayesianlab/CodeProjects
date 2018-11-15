function [ P0, Phi, RRp ] = kowKalmanInitRecursion(Transition, R, statevariance)

lt = length(Transition);
Phi = [Transition; eye(lt-1), zeros(lt-1,1)];
RRp = R*statevariance*R';
P0 = reshape((eye(lt^2) - kron(Phi,Phi))\RRp(:), lt,lt);

end

