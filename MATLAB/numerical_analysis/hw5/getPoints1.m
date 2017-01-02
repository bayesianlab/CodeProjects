function [ points ] = getPoints1( error )
points = round(1/sqrt( 6 * error ) );
end

