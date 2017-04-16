function [ confInt ] = ellipse(mu, sigma, alpha, df)
% Rotation angle is the dot product of the first eigenvalue with
% x-axis vector
s12 = sigma(1,2);
if s12 > 0 
    [vect, vals] = eig(sigma); 
    axisVect = [1;0];
    theta = 0:.01:2*pi;
    rotationAngle = acos(dot(axisVect, vect(:,1)));
else
    [vect, vals] = eig(sigma); 
    axisVect = [0;1];
    theta = 0:.01:2*pi;
    rotationAngle = acos(dot(axisVect, vect(:,2)));
end
% Rotation matrix turns the ellipse to the proper coordinate system
rotationMatrix = [cos(rotationAngle), -sin(rotationAngle);
                    sin(rotationAngle), cos(rotationAngle)];
% Projects the ellipse out to the specified confidence area
chiCrit = chi2inv(alpha, df);
projX = (chiCrit*vals(1,1))^.5;
projY = (chiCrit*vals(2,2))^.5;
x = projX.*cos(theta);
y = projY.*sin(theta);
confInt = rotationMatrix*[x;y] + mu;
end

