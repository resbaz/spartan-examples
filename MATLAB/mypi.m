function mypi = approxpi(n)

% Input: n = number of points to generate
%        Default is n = 1e6
%        Larger values of n should perform better

if nargin < 1
    n = 1e6;
end

% Generate uniformly distributed points in 

% [0, 1] x [0, 1]

xy = rand(n, 2); 

% Compute distance from (0.5, 0.5)

r = sqrt((xy(:,1)-0.5).^2+(xy(:,2)-0.5).^2); 

% Count fraction of points within 1/2 unit of (0.5, 0.5)

frac = sum(r <= 0.5) / n; 

% Since square has side 1, circle has radius (1/2) 
% and should have area of pi*(1/2)^2
% frac is approximately pi/4 so pi is approximately 4*frac

mypi = 4*frac;

