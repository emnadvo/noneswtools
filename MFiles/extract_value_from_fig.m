%http://www.mathworks.com/matlabcentral/answers/100687-how-do-i-extract-data-from-matlab-figures
% How get values from fig file - Matlab

open('example.fig');

h = gcf; %current figure handle
axesObjs = get(h, 'Children');  %axes handles
dataObjs = get(axesObjs, 'Children'); %handles to low-level graphics objects in axes
objTypes = get(dataObjs, 'Type');  %type of low-level graphics object

%    NOTE : Different objects like 'Line' and 'Surface' will store data differently. Based on the 'Type', you can search the documentation for how each type stores its data.

% Lines of code similar to the following would be required to bring the data to MATLAB Workspace:

xdata = get(dataObjs, 'XData');  %data from low-level grahics objects
ydata = get(dataObjs, 'YData');
zdata = get(dataObjs, 'ZData');
