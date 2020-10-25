function out = ssteam(fun,in1,in2,in3)
% +--------------------------------------------------------+
% |                                                        |
% |           SKODA WATER-STEAM properties IF97            |  
% |           =================================            |
% |                                                        |
% |           version 1.0.0.0                              |
% |           Adam Novy            25.10.2012              |
% |                                                        |
% +--------------------------------------------------------+
%
% out = ssteam(fun,in1,in2,in3)
% 
% for the dimensions, see below and be careful about the dimensions
%
% input:
% ------
% 'fun' ... string, function name se below
%  in1  ... \
%  in2  ...  > input parameters
%  in3  ... /
%
% the function accepts those dimensions:
%
%  var \ param     in1      in2      in3      out
% ------------------------------------------------
%  variant 0:      M×N      M×N       -       M×N
%  variant 1:      1×1      M×N       -       M×N
%  variant 2:      M×N      1×1       -       M×N
%  variant 3:      M×1      1×N       -       M×N
%  variant 4:      1×M      N×1       -       N×M
%  variant 5:      M×N       -        -       M×N
%  variant 6:      1×1      1×1      1×1      1×1
% ------------------------------------------------
% 
% output values:
% calculated property (returns NaN in case of problem inside the library)
%
% IMPORTANT!!!                                          
% Call 'open'   once, prior to any calculation  (loads the library)
% Call 'close'  when no more use of the library (unloads the library
%
% +--------------------------------------------------------+
% |  p ... pressure                            MPa         |
% |  t ... temperature                         degC        |
% |  h ... enthalpy                            kJ/Kg       |
% |  v ... specific volume                     m3/kg       |
% |  s ... entropy                             kJ/(Kg.K)   |
% |  u ... internal energy                     kJ/Kg       |
% |  x ... dryness <0,1>                       -           |
% |  w ... speed of sound                      m/s         |
% |  cp .. specific isobaric heat capacity     kJ/(Kg.K)   |
% |  cv .. specific isochoric heat capacity    kJ/(Kg.K)   |
% |                                                        |
% |  mi .. dynamic viscosity                   Pa.s        |
% |  ny .. kinematic viscosity                 m2/s        |
% |  la .. thermal conductivity                W/(K.m)     |
% |  ka .. isentropic coefficient              -           |
% |  ga .. surface tension                     mN/m        |
% +--------------------------------------------------------+

% direct functions  
%   't_ph'
%   't_ps'
%   'v_pt'
%   'v_ph'
%   'v_ps'
%   'h_pt'
%   'h_ps'
%   'h_ps_meta'	      metastable region
%   's_pt'
%   's_ph'
%   'w_pt'
%   'w_ph'
%   'w_ps'
%   'cppt'
%   'cpph'
%   'cpps'
%   'cvpt'
%   'cvph'
%   'cvps'
% iterative functions
%   'p_vt'
%   'p_ts'
%   'p_hs'
%   'p_hs_meta'       metastable region
%   'p_vh'
%   'p_vs'
%   'v_ts'
%   'h_vt'
%   'h_ts'
%   'h_vs'
%   's_vt'
%   'w_vt'
%   'cpvt'
%   'cvvt'
%   'p_th'
%   'h_pv'
%   's_pv'
%   't_hx'
%   't_sx'
% region identification        
%   'region_pt'
%   'region_ph'
%   'region_ps'
%   'region_hs'
%   'region_ph_meta'  metastable region
%   'region_ps_meta'  metastable region
% saturation line
%   'p_sat_t'
%   't_sat_p'
%   'v_lsat_p'        saturated liquid phase
%   'h_lsat_p'        saturated liquid phase
%   's_lsat_p'        saturated liquid phase
%   'w_lsat_p'        saturated liquid phase
%   'cplsat_p'        saturated liquid phase
%   'cvlsat_p'        saturated liquid phase
%   'v_gsat_p'        saturated gas phase
%   'h_gsat_p'        saturated gas phase
%   's_gsat_p'        saturated gas phase
%   'w_gsat_p'        saturated gas phase
%   'cpgsat_p'        saturated gas phase
%   'cvgsat_p'        saturated gas phase
% dryness related
%   'v_xt'
%   'h_xt'
%   's_xt'
%   'w_xt'
%   'cpxt'
%   'cvxt'
%   'v_xp'
%   'h_xp'
%   's_xp'
%   'w_xp'
%   'cp_xp'
%   'cv_xp'
% steam quality 
%   'x_pt'
%   'x_ph'
%   'x_ps'
% dynamic viscosity
%   'mi_tvp'          pressure for valid region testing only
%   'mi_pt'
%   'mi_ph'
%   'mi_ps'
% kinematic viscosity            
%   'ny_tvp'          pressure for valid region testing only
%   'ny_pt'
%   'ny_ph'
%   'ny_ps'
% internal energy            
%   'u_lsat_p'        saturated liquid phase
%   'u_gsat_p'        saturated gas phase
%   'u_lsat_t'        saturated liquid phase
%   'u_gsat_t'        saturated gas phase
%   'u_pt'
%   'u_ph'
%   'u_ps'
% thermal conductivity
%   'la_tvp'          pressure for valid region testing only
%   'la_pt'
%   'la_ph'
%   'la_ps'
% isentropic ceofficient kapa                                
%   'ka_pt'
%   'ka_ph'
%   'ka_ps'
%   'ka_vt'
%   'ka_xt'
%   'ka_xp'
%   'ka_lsat_p'       saturated liquid phase
%   'ka_gsat_p'       saturated gas phase
% surface tension
%   'ga_t'

% remarks
% speed of sound and kapa in wet steam are calculated according to the formula 
% w = ( sqrt(dp/dro) at const entropy )

%===============================================================================

    fun=lower(fun);
    
    % loading and unloading the library
    switch fun  
        case 'open'
            if (~libisloaded('IF97cpp'))
                loadlibrary('IF97cpp','IF97cpp.h');
                if (libisloaded('IF97cpp'))
                    calllib('IF97cpp','IF97cpp_if97_initiate');
                    out =  1;
                else
                    out = 0;
                end
            else
                out = 1;
            end
            return;
        case 'close'
            if (libisloaded('IF97cpp'))
                unloadlibrary('IF97cpp');
            end    
            if (libisloaded('IF97cpp'))
                out = 0;
            else
                out = 1;
            end
            return    
    end        
    
    if (~libisloaded('IF97cpp'))
        out = [];
        error('error: libarry IF97cpp not loaded, see help');
        return;
    end     
    
    if (nargin<2)
        out = [];
        display('not enough parameters');
        return;
    end
    
    if (~libisloaded('IF97cpp'))
        out = [];
        display('error: library IF97cpp not loaded');
        return;
    end    
    
    if (nargin==2)
        out = nan(size(in1));
        varianta = 5;
    elseif (nargin==3)
        if (size(in1)==size(in2))
            out = nan(size(in1));
            varianta = 0; 
        elseif (isscalar(in1))
            out = nan(size(in2));
            varianta = 1;
        elseif (isscalar(in2))
            out = nan(size(in1));
            varianta = 2;
        elseif (isvector(in1) && isvector(in2))   
            if (size(in1,1)==size(in2,1) || size(in1,2)==size(in2,2))
                out = [];
                error('error: parameters dimensions incorrect');
                return;    
            end
            if (size(in1,1)~=1)
                out = nan(length(in1),length(in2));
                varianta = 3;
            else
                out = nan(length(in2),length(in1));
                varianta = 4;
            end      
            else
                out = [];
                error('error: parameters dimensions incorrect');
                return;
            end
    elseif (nargin==4)
        if (isscalar(in1) && isscalar(in2) && isscalar(in3));
            out = nan;
            varianta = 6;
        else
            error('error: 3 scalar parameters only supported by this function');
            out = [];
        return;
        end
    else
        error('error: parameters count incorrect');
        out = [];
        return;
    end    
  
    [m n] = size(out);
    % cycle to fill the whole ouptut matrix(vector,scalar respectively)
    
    i1 = 1;
    i2 = 1;
    i3 = 1;
    j1 = 1;
    j2 = 1;
    j3 = 1;
    io = 1;
    jo = 1;
    
    while (true)
    
        switch fun
        
% direct functions  
        case 't_ph'
            out(io,jo) = calllib('IF97cpp','IF97cpp_t_ph',in1(i1,j1),in2(i2,j2));
        case 't_ps'
            out(io,jo) = calllib('IF97cpp','IF97cpp_t_ps',in1(i1,j1),in2(i2,j2));
        case 'v_pt'
            out(io,jo) = calllib('IF97cpp','IF97cpp_v_pt',in1(i1,j1),in2(i2,j2));
        case 'v_ph'
            out(io,jo) = calllib('IF97cpp','IF97cpp_v_ph',in1(i1,j1),in2(i2,j2));
        case 'v_ps'
            out(io,jo) = calllib('IF97cpp','IF97cpp_v_ps',in1(i1,j1),in2(i2,j2));
        case 'h_pt'
            out(io,jo) = calllib('IF97cpp','IF97cpp_h_pt',in1(i1,j1),in2(i2,j2));
        case 'h_ps'
            out(io,jo) = calllib('IF97cpp','IF97cpp_h_ps',in1(i1,j1),in2(i2,j2));
        case 'h_ps_meta'
            out(io,jo) = calllib('IF97cpp','IF97cpp_h_ps_meta',in1(i1,j1),in2(i2,j2));
        case 's_pt'
            out(io,jo) = calllib('IF97cpp','IF97cpp_s_pt',in1(i1,j1),in2(i2,j2));
        case 's_ph'
            out(io,jo) = calllib('IF97cpp','IF97cpp_s_ph',in1(i1,j1),in2(i2,j2));
        case 'w_pt'
            out(io,jo) = calllib('IF97cpp','IF97cpp_w_pt',in1(i1,j1),in2(i2,j2));
        case 'w_ph'
            out(io,jo) = calllib('IF97cpp','IF97cpp_w_ph',in1(i1,j1),in2(i2,j2));
        case 'w_ps'
            out(io,jo) = calllib('IF97cpp','IF97cpp_w_ps',in1(i1,j1),in2(i2,j2));
        case 'cppt'
            out(io,jo) = calllib('IF97cpp','IF97cpp_cppt',in1(i1,j1),in2(i2,j2));
        case 'cpph'
            out(io,jo) = calllib('IF97cpp','IF97cpp_cpph',in1(i1,j1),in2(i2,j2));
        case 'cpps'
            out(io,jo) = calllib('IF97cpp','IF97cpp_cpps',in1(i1,j1),in2(i2,j2));
        case 'cvpt'
            out(io,jo) = calllib('IF97cpp','IF97cpp_cvpt',in1(i1,j1),in2(i2,j2));
        case 'cvph'
            out(io,jo) = calllib('IF97cpp','IF97cpp_cvph',in1(i1,j1),in2(i2,j2));
        case 'cvps'
            out(io,jo) = calllib('IF97cpp','IF97cpp_cvps',in1(i1,j1),in2(i2,j2));
 % iterative functions
        case 'p_vt'
            out(io,jo) = calllib('IF97cpp','IF97cpp_p_vt',in1(i1,j1),in2(i2,j2));            
        case 'p_ts'
            out(io,jo) = calllib('IF97cpp','IF97cpp_p_ts',in1(i1,j1),in2(i2,j2));            
        case 'p_hs'
            out(io,jo) = calllib('IF97cpp','IF97cpp_p_hs',in1(i1,j1),in2(i2,j2));            
        case 'p_hs_meta'
            out(io,jo) = calllib('IF97cpp','IF97cpp__p_hs_meta',in1(i1,j1),in2(i2,j2));            
        case 'p_vh'
            out(io,jo) = calllib('IF97cpp','IF97cpp_p_vh',in1(i1,j1),in2(i2,j2));            
        case 'p_vs'
            out(io,jo) = calllib('IF97cpp','IF97cpp_p_vs',in1(i1,j1),in2(i2,j2));            
        case 'v_ts'
            out(io,jo) = calllib('IF97cpp','IF97cpp_v_ts',in1(i1,j1),in2(i2,j2));            
        case 'h_vt'
            out(io,jo) = calllib('IF97cpp','IF97cpp_h_vt',in1(i1,j1),in2(i2,j2));            
        case 'h_ts'
            out(io,jo) = calllib('IF97cpp','IF97cpp_h_ts',in1(i1,j1),in2(i2,j2));            
        case 'h_vs'
            out(io,jo) = calllib('IF97cpp','IF97cpp_h_vs',in1(i1,j1),in2(i2,j2));            
        case 's_vt'
            out(io,jo) = calllib('IF97cpp','IF97cpp_s_vt',in1(i1,j1),in2(i2,j2));            
        case 'w_vt'
            out(io,jo) = calllib('IF97cpp','IF97cpp_w_vt',in1(i1,j1),in2(i2,j2));            
        case 'cpvt'
            out(io,jo) = calllib('IF97cpp','IF97cpp_cpvt',in1(i1,j1),in2(i2,j2));            
        case 'cvvt'
            out(io,jo) = calllib('IF97cpp','IF97cpp_cvvt',in1(i1,j1),in2(i2,j2));            
        case 'p_th'
            out(io,jo) = calllib('IF97cpp','IF97cpp_p_th',in1(i1,j1),in2(i2,j2));            
        case 'h_pv'
            out(io,jo) = calllib('IF97cpp','IF97cpp_h_pv',in1(i1,j1),in2(i2,j2));            
        case 's_pv'
            out(io,jo) = calllib('IF97cpp','IF97cpp_s_pv',in1(i1,j1),in2(i2,j2));            
        case 't_hx'
            out(io,jo) = calllib('IF97cpp','IF97cpp_t_hx',in1(i1,j1),in2(i2,j2));            
        case 't_sx'
            out(io,jo) = calllib('IF97cpp','IF97cpp_t_sx',in1(i1,j1),in2(i2,j2));            
% region identification        
        case 'region_pt'
            out(io,jo) = calllib('IF97cpp','IF97cpp_region_pt',in1(i1,j1),in2(i2,j2));            
        case 'region_ph'
            out(io,jo) = calllib('IF97cpp','IF97cpp_region_ph',in1(i1,j1),in2(i2,j2));            
        case 'region_ps'
            out(io,jo) = calllib('IF97cpp','IF97cpp_region_ps',in1(i1,j1),in2(i2,j2));            
        case 'region_hs'
            out(io,jo) = calllib('IF97cpp','IF97cpp_region_hs',in1(i1,j1),in2(i2,j2));            
        case 'region_ph_meta'
            out(io,jo) = calllib('IF97cpp','IF97cpp_region_ph_meta',in1(i1,j1),in2(i2,j2));            
        case 'region_ps_meta'
            out(io,jo) = calllib('IF97cpp','IF97cpp_region_ps_meta',in1(i1,j1),in2(i2,j2));            
% saturation line
        case 'p_sat_t'
            out(io,jo) = calllib('IF97cpp','IF97cpp_p_sat_t',in1(i1,j1));            
        case 't_sat_p'
            out(io,jo) = calllib('IF97cpp','IF97cpp_t_sat_p',in1(i1,j1));            
        case 'v_lsat_p'
            out(io,jo) = calllib('IF97cpp','IF97cpp_v_lsat_p',in1(i1,j1));            
        case 'h_lsat_p'
            out(io,jo) = calllib('IF97cpp','IF97cpp_h_lsat_p',in1(i1,j1));            
        case 's_lsat_p'
            out(io,jo) = calllib('IF97cpp','IF97cpp_s_lsat_p',in1(i1,j1));            
        case 'w_lsat_p'
            out(io,jo) = calllib('IF97cpp','IF97cpp_w_lsat_p',in1(i1,j1));            
        case 'cplsat_p'
            out(io,jo) = calllib('IF97cpp','IF97cpp_cplsat_p',in1(i1,j1));            
        case 'cvlsat_p'
            out(io,jo) = calllib('IF97cpp','IF97cpp_cvlsat_p',in1(i1,j1));            
        case 'v_gsat_p'
            out(io,jo) = calllib('IF97cpp','IF97cpp_v_gsat_p',in1(i1,j1));            
        case 'h_gsat_p'
            out(io,jo) = calllib('IF97cpp','IF97cpp_h_gsat_p',in1(i1,j1));            
        case 's_gsat_p'
            out(io,jo) = calllib('IF97cpp','IF97cpp_s_gsat_p',in1(i1,j1));            
        case 'w_gsat_p'
            out(io,jo) = calllib('IF97cpp','IF97cpp_w_gsat_p',in1(i1,j1));            
        case 'cpgsat_p'
            out(io,jo) = calllib('IF97cpp','IF97cpp_cpgsat_p',in1(i1,j1));            
        case 'cvgsat_p'
            out(io,jo) = calllib('IF97cpp','IF97cpp_cvgsat_p',in1(i1,j1));            
% dryness related
        case 'v_xt'
            out(io,jo) = calllib('IF97cpp','IF97cpp_v_xt',in1(i1,j1),in2(i2,j2));            
        case 'h_xt'
            out(io,jo) = calllib('IF97cpp','IF97cpp_h_xt',in1(i1,j1),in2(i2,j2));            
        case 's_xt'
            out(io,jo) = calllib('IF97cpp','IF97cpp_s_xt',in1(i1,j1),in2(i2,j2));            
        case 'w_xt'
            out(io,jo) = calllib('IF97cpp','IF97cpp_w_xt',in1(i1,j1),in2(i2,j2));            
        case 'cpxt'
            out(io,jo) = calllib('IF97cpp','IF97cpp_cpxt',in1(i1,j1),in2(i2,j2));            
        case 'cvxt'
            out(io,jo) = calllib('IF97cpp','IF97cpp_cvxt',in1(i1,j1),in2(i2,j2));            
        case 'v_xp'
            out(io,jo) = calllib('IF97cpp','IF97cpp_v_xp',in1(i1,j1),in2(i2,j2));            
        case 'h_xp'
            out(io,jo) = calllib('IF97cpp','IF97cpp_h_xp',in1(i1,j1),in2(i2,j2));            
        case 's_xp'
            out(io,jo) = calllib('IF97cpp','IF97cpp_s_xp',in1(i1,j1),in2(i2,j2));            
        case 'w_xp'
            out(io,jo) = calllib('IF97cpp','IF97cpp_w_xp',in1(i1,j1),in2(i2,j2));            
        case 'cp_xp'
            out(io,jo) = calllib('IF97cpp','IF97cpp_cpxp',in1(i1,j1),in2(i2,j2));            
        case 'cv_xp'
            out(io,jo) = calllib('IF97cpp','IF97cpp_cvxp',in1(i1,j1),in2(i2,j2));            
% steam quality 
        case 'x_pt'
            out(io,jo) = calllib('IF97cpp','IF97cpp_x_pt',in1(i1,j1),in2(i2,j2));            
        case 'x_ph'
            out(io,jo) = calllib('IF97cpp','IF97cpp_x_ph',in1(i1,j1),in2(i2,j2));            
        case 'x_ps'
            out(io,jo) = calllib('IF97cpp','IF97cpp_x_ps',in1(i1,j1),in2(i2,j2));            
% dynamic viscosity
        case 'mi_tvp'
            out(io,jo) = calllib('IF97cpp','IF97cpp_dynamic_viscosity_tvp',in1(i1,j1),in2(i2,j2),in3(i3,j3));            
        case 'mi_pt'
            out(io,jo) = calllib('IF97cpp','IF97cpp_dynamic_viscosity_pt',in1(i1,j1),in2(i2,j2));            
        case 'mi_ph'
            out(io,jo) = calllib('IF97cpp','IF97cpp_dynamic_viscosity_ph',in1(i1,j1),in2(i2,j2));            
        case 'mi_ps'
            out(io,jo) = calllib('IF97cpp','IF97cpp_dynamic_viscosity_ps',in1(i1,j1),in2(i2,j2));            
% kinematic viscosity            
        case 'ny_tvp'
            out(io,jo) = calllib('IF97cpp','IF97cpp_kinematic_viscosity_tvp',in1(i1,j1),in2(i2,j2),in3(i3,j3));            
        case 'ny_pt'
            out(io,jo) = calllib('IF97cpp','IF97cpp_kinematic_viscosity_pt',in1(i1,j1),in2(i2,j2));            
        case 'ny_ph'
            out(io,jo) = calllib('IF97cpp','IF97cpp_kinematic_viscosity_ph',in1(i1,j1),in2(i2,j2));            
        case 'ny_ps'
            out(io,jo) = calllib('IF97cpp','IF97cpp_kinematic_viscosity_ps',in1(i1,j1),in2(i2,j2));
% internal energy            
        case 'u_lsat_p'
            out(io,jo) = calllib('IF97cpp','IF97cpp_u_lsat_p',in1(i1,j1));
        case 'u_gsat_p'
            out(io,jo) = calllib('IF97cpp','IF97cpp_u_gsat_p',in1(i1,j1));
        case 'u_lsat_t'
            out(io,jo) = calllib('IF97cpp','IF97cpp_u_lsat_t',in1(i1,j1));
        case 'u_gsat_t'
            out(io,jo) = calllib('IF97cpp','IF97cpp_u_gsat_t',in1(i1,j1));
        case 'u_pt'
            out(io,jo) = calllib('IF97cpp','IF97cpp_u_pt',in1(i1,j1),in2(i2,j2));
        case 'u_ph'
            out(io,jo) = calllib('IF97cpp','IF97cpp_u_ph',in1(i1,j1),in2(i2,j2));
        case 'u_ps'
            out(io,jo) = calllib('IF97cpp','IF97cpp_u_ps',in1(i1,j1),in2(i2,j2));
% thermal conductivity
        case 'la_tvp'
            out(io,jo) = calllib('IF97cpp','IF97cpp_thermal_conductivity_tvp',in1(i1,j1),in2(i2,j2),in3(i3,j3));
        case 'la_pt'
            out(io,jo) = calllib('IF97cpp','IF97cpp_thermal_conductivity_pt',in1(i1,j1),in2(i2,j2));
        case 'la_ph'
            out(io,jo) = calllib('IF97cpp','IF97cpp_thermal_conductivity_ph',in1(i1,j1),in2(i2,j2));
        case 'la_ps'
            out(io,jo) = calllib('IF97cpp','IF97cpp_thermal_conductivity_ps',in1(i1,j1),in2(i2,j2));
% isentropic ceofficient kappa                                
        case 'ka_pt'
            out(io,jo) = calllib('IF97cpp','IF97cpp_isentropic_coefficient_pt',in1(i1,j1),in2(i2,j2));
        case 'ka_ph'
            out(io,jo) = calllib('IF97cpp','IF97cpp_isentropic_coefficient_ph',in1(i1,j1),in2(i2,j2));
        case 'ka_ps'
            out(io,jo) = calllib('IF97cpp','IF97cpp_isentropic_coefficient_ps',in1(i1,j1),in2(i2,j2));
        case 'ka_vt'
            out(io,jo) = calllib('IF97cpp','IF97cpp_isentropic_coefficient_vt',in1(i1,j1),in2(i2,j2));
        case 'ka_xt'
            out(io,jo) = calllib('IF97cpp','IF97cpp_isentropic_coefficient_xt',in1(i1,j1),in2(i2,j2));
        case 'ka_xp'
            out(io,jo) = calllib('IF97cpp','IF97cpp_isentropic_coefficient_xp',in1(i1,j1),in2(i2,j2));
        case 'ka_lsat_p'
            out(io,jo) = calllib('IF97cpp','IF97cpp_isentropic_coefficient_lsat_p',in1(i1,j1));
        case 'ka_gsat_p'
            out(io,jo) = calllib('IF97cpp','IF97cpp_isentropic_coefficient_gsat_p',in1(i1,j1));
% surface tension
        case 'ga_t'
            out(io,jo) = calllib('IF97cpp','IF97cpp_surface_tension_t',in1(i1,j1));
% otherwise display error message            
        otherwise
            error('Unknown function');
            out = [];
            return;
        end % switch
        
% loop control logic (or no logic :-) )        
        if (varianta==0)
            if (i1<m)
              i1 = i1 + 1;
            elseif (j1<n)
              i1 = 1;
              j1 = j1 + 1;   
            else
              return;
            end
            i2 = i1;
            j2 = j1;
            io = i1;
            jo = j1;
        elseif (varianta==1)
            if (i2<m)
              i2 = i2 + 1;
            elseif (j2<n)
              i2 = 1;
              j2 = j2 + 1;   
            else
              return;
            end
            io = i2;
            jo = j2;
        elseif (varianta==3)
            if (i1<m)
              i1 = i1 + 1;
            elseif (j2<n)
              i1 = 1;
              j2 = j2 + 1;   
            else
              return;
            end
            io = i1;
            jo = j2;
         elseif (varianta==4)
            if (j1<n)
              j1 = j1 + 1;
            elseif (i2<m)
              j1 = 1;
              i2 = i2 + 1;   
            else
              return;
            end
            io = i2;
            jo = j1;
        elseif (varianta==5 || varianta==2)     
            if (i1<m)
              i1 = i1 + 1;
            elseif (j1<n)
              i1 = 1;
              j1 = j1 + 1;   
            else
              return;
            end
            io = i1;
            jo = j1;
        elseif (varianta==6)
            return;
        else
            error('error: unexpected parameters');
            return;
        end
        
        
        
        
    end % while true
end % function
