function status = get_scaled_blade(source_prof_data,new_prof_data)
%
%   Function get data from source profile and made scale for new data.
%   It's supposed that scale is with conservation t/c parameter. 
%

% Values of source blade

status = 0;

if isstruct(source_prof_data) ~= 1 || isstruct(new_prof_data) ~= 1
    disp('Invalid data type of input parameters');
    return;
end

chord_id = 2;
t_c_limit = 0.1;
% Dp_main = 1.39;
% L_main = 0.140;
% NBlades_main = 150;
% c_hub_main = 0.040;

Dp_main = NaN;
L_main = NaN;
NBlades_main = NaN;
c_hub_main = NaN;
L_D = NaN;
t_hub = NaN;
t_tip = NaN;
t_c_hub = NaN;
c_tip_main = NaN;
corr_t_c_tip = NaN;
new_Dp = NaN;


if isstruct(source_prof_data) == 1
    Dp_main = source_prof_data.Dp;
    L_main = source_prof_data.L;
    NBlades_main = source_prof_data.NBlades;
    c_hub_main = source_prof_data.sParameters(chord_id,1);
    c_tip_main = source_prof_data.sParameters(chord_id,end);
end

if Dp_main > 0
    L_D = L_main/Dp_main;
end

if NBlades_main > 0
    t_hub = get_pitch(Dp_main,NBlades_main);
    t_tip = get_pitch((Dp_main+2*L_main),NBlades_main);
end

t_c_hub = t_hub/c_hub_main;
t_c_tip = t_tip/c_tip_main;
% c_tip_main = t_tip/t_c_hub;
% corr_t_c_tip = t_tip/c_tip_main;

%Scale blade
%new_Dp = 1.52;
new_Dp = new_prof_data.Dp; 
scale = new_Dp/Dp_main;
new_c_hub = (scale*c_hub_main);
new_NBlades = floor((pi*new_Dp)/(t_c_hub*new_c_hub));

new_t_hub = get_pitch(new_Dp,New_NBlades);
new_t_c = new_t_hub/new_c_hub;

if abs((new_t_c-t_c_hub)/t_c_hub)*100 > t_c_limit
    disp('t/c for new blade was to much different then source blade have!');
end

scale_tip = (new_prof_data.Dp+2*new_prof_data.L)/(Dp_main+2*L_main);
new_c_tip = (scale_tip*c_tip_main);

new_t_tip = get_pitch((new_Dp+2*new_prof_data.L),New_NBlades);

new_prof_data = source_prof_data;
new_prof_data.sParameters(chord_id,1) = new_c_hub;
new_prof_data.sParameters(chord_id,end) = new_t_hub;
end


function pitch = get_pitch(Dp, NBlades)
    if NBlades == 0
        disp('Divide by 0 is not allowed!');
        pitch = 0;
        return
    end
    
    pitch = (pi*Dp)/NBlades;
end
