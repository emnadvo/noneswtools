%dev script for lean curve
clear all;
close all;

mm_to_m = 1000;
RadiusHub = 505.5;
RadiusTip = 535.25;
Blade_cnt = 82;

pitch = (pi*2*RadiusHub*mm_to_m)/Blade_cnt;
pitch_angle = 2*asind(pitch/(2*RadiusHub*mm_to_m));


LEAN_LIMITS = [ pitch_angle/4,...
                45,...
                30 ];

LEAN = [ -0.45, ...
         0.75,...
         0.60,...
         0.80,...
         0.20,...
         0.60,...
         0.20 ];
     

     
figure(100);
parent = gco;

hold on;
grid on;

% format = cell2str('Marker','--','Color','b');
plotls_leanlimits(parent,RadiusHub,RadiusTip,LEAN_LIMITS);  % [handlePlotLIMITS, handleFigureLIMITS ] =

format = cell2str('Marker','o','Color','r','MarkerEdgeColor','red','MarkerSize',4);
plotls_leanpoly(parent,RadiusHub,RadiusTip,LEAN_LIMITS,LEAN,format);

format = cell2str('Color','black','MarkerSize',5);
plotls_leancurve(parent,RadiusHub,RadiusTip,LEAN_LIMITS,LEAN,format); 
