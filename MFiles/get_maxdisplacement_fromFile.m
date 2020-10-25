function [ MAXDISPLACEMENT ] = get_maxdisplacement_fromFile( filename )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
    MAXDISPLACEMENT = -1;
    DATA = [];
    
    SOURCE = importdata(filename);
    
    if (class(SOURCE) == 'struct')
        DATA = SOURCE.data;
    elseif (class(SOURCE) == 'double')
        DATA = SOURCE;
    end
    
    [rw,col] = size(DATA);
    if (col >= 9)
       DISPL = sqrt(DATA(:,4).^2+DATA(:,5).^2+DATA(:,6).^2+DATA(:,7).^2+DATA(:,8).^2+DATA(:,9).^2);
       MAXDISPLACEMENT = max(DISPL);       
    end
    
    return;

end

