function [OUTBLADE] = regenerate_blade(oldBlade)
% BastlMaster 333.3.6 (c) Všechna káva vypražena
% 16.7.2015
%
% [in] oldBlade - structure with necessary properties
    
    OUTBLADE = NaN;
    RAD_ID = 1;
    MI_ID = 2;
    
    if isstruct(oldBlade) == 0
        disp('Your input parameter is not structure!');
        return;
    elseif isfield(oldBlade,'sParameters') == 0
        disp('Your input structure missing field with name sParameters!');
        return;
    elseif isfield(oldBlade,'sLeadingPoint') == 0
        disp('Your input structure missing field with name sLeadingPoint!');
        return;
    elseif isfield(oldBlade,'hubDiameter') == 0
        disp('Your input structure missing field with name hubDiameter!');
        return;
    elseif isfield(oldBlade,'hubParam') == 0
        disp('Your input structure missing field with name hubParam!');
        return;      
    elseif isfield(oldBlade,'shroudParam') == 0
        disp('Your input structure missing field with name shroudParam!');
        return;       
    elseif isfield(oldBlade,'LEAN_LIMITS') == 0
        disp('Your input structure missing field with name LEAN_LIMITS!');
        return;
    elseif isfield(oldBlade,'LEAN') == 0
        disp('Your input structure missing field with name LEAN!');
        return 
    elseif isfield(oldBlade,'SWEEP_LIMITS') == 0
        disp('Your input structure missing field with name SWEEP_LIMITS!');
        return 
    elseif isfield(oldBlade,'SWEEP') == 0
        disp('Your input structure missing field with name SWEEP!');
        return;
    end
         
    
    OUTBLADE = oldBlade;
    SERVICEPATH='C:\Data\bld_dev\BladeMaster.3.4.0\matlab\lib_geom';
    addpath(SERVICEPATH);
      
    [OUTBLADE.XY_2D, OUTBLADE.GIndex2D] = generate_2D(OUTBLADE.hubDiameter,...
                                                      OUTBLADE.sParameters,...
                                                      OUTBLADE.sLeadingPoint);

    OUTBLADE.SIDEWALL = [ OUTBLADE.hubDiameter,...
                          (OUTBLADE.shroudParam(RAD_ID)- OUTBLADE.hubDiameter/2),...
                          OUTBLADE.hubParam(MI_ID),...
                          OUTBLADE.shroudParam(MI_ID)];

    SECTIONS = OUTBLADE.hubDiameter/2 + OUTBLADE.sParameters(1,:);
                      
    [OUTBLADE.XYZ_3D, OUTBLADE.SC] = generate_3d_v2(OUTBLADE.XY_2D,...
                                                    OUTBLADE.SIDEWALL,...
                                                    OUTBLADE.LEAN_LIMITS,...
                                                    OUTBLADE.LEAN,...
                                                    OUTBLADE.SWEEP_LIMITS,...
                                                    OUTBLADE.SWEEP,...
                                                    SECTIONS);    
   return; 
end
        