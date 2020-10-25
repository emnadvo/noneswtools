function [retVal] = get_circ_anulus_area(radius_min, radius_max, angle)
%   Function calculated circle anulus area
%   in1: radius_min - minimal radius of your anulus
%   in2: radius_max - maximal radius of your anulus
%   in3: angle - angle of your anulus
%   out: retval = anulus area

    Rmin = radius_min;
    Rmax = radius_max;
    alfa = angle;    
    retVal = NaN;
    
    retVal = (pi*alfa*(Rmax^2 - Rmin^2))/360;
