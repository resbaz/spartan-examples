angle = 0:.1*pi:3*pi;
             radius = exp(angle/20);
             polar(angle,radius),...
             title('An Example Polar Plot'),...
             grid
print -deps polar-plot.ps;
quit;

