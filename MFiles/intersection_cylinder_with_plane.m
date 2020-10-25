r=10; % cylinder radius
sect=40; % number of sectors of cylinder base
% Plane equation: A*(x-x0)+B*(y-y0)+C*(z-z0)=0
vd=[1 1 1]; % vd=[A B C];
v0=[0,0,20]; % v0=[x0 y0 z0];
fi=linspace(-pi,pi,sect);
x=r*cos(fi);
y=r*sin(fi);
z=1/vd(3)*(-vd(1)*(x-v0(1))-vd(2)*(y-v0(2)))+v0(3);
zM=max(z);
zm=min(z);
if zM*zm >= 0
   zb=zeros(1,sect);
else
   zb=zm*ones(1,sect);
end
X=[x;x];
Y=[y;y];
Z=[zb;z];
surf(X,Y,Z)
shading interp
colormap([.8 .8 .8])
camlight('right','local')
