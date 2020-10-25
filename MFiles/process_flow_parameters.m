function retVal = process_flow_parameters(varargin)
%   Function calculated circle anulus area
%   in1: domain_data - structure with all inport parameters for calculation
%   out: retval = status

%    cp = (i0t - i2is) / (T0t - T2is)            ... merna tepelna kapacita
%    Rkonst = (p0t*v0t/T0t + p2is*v2is/T2is) / 2 ... plynova konstanta
%    mi = 8314.3 / Rkonst                        ... molekulova hmotnost
%    kapaIG = 1 / (1 - Rkonst/cp)                ... Poissonova konstanta cp/cv idealniho plynu
%    eta                                         ... dynamicka viskozita
%    lambda                                      ... merna tepelna vodivost



    addpath('/home/mnadvornik/bin/XSteam/');
    %addpath('./IF97cpp_Matlab64/');
    
    %loadlibrary('IF97cpp');
    
    MPa_to_Bar = 10;
    Pa_to_Bar = 1/10^5;
    Kelvin_to_Celsius = -273.15;
    Celsius_to_Kelvin = Kelvin_to_Celsius*-1;
    Kg_to_base = 10^3;
        
    if length(varargin) == 0
        disp('All input values are default');
        domaindata.row0.rmin = 0.87748;
        domaindata.row0.rmax = 1.18888;
        domaindata.row0.bld = 56;

        domaindata.row1.rmin = 0.8775;
        domaindata.row1.rmax = 1.4135;
        domaindata.row1.bld = 71;
        
        domaindata.row2.rmin = 1.26412;
        domaindata.row2.rmax = 2.20123;
        domaindata.row2.bld = 64;
        
        domaindata.row3.rmin = 0.865;
        domaindata.row3.rmax = 1.8200;
        domaindata.row3.bld = 48;        
    
        domaindata.medium.p0 = 38420;   %[Pa]
        domaindata.medium.T0 = 348.0; %[K]
        domaindata.medium.h0 = 2578.190; %[KJ/kg]
        domaindata.medium.p2 = 4850;    %[Pa]        
    else
        domaindata = varargin;
    end
      
    domaindata.row0.alfa = 360/domaindata.row0.bld;
    domaindata.row0.area = get_circ_anulus_area(domaindata.row0.rmin, domaindata.row0.rmax, domaindata.row0.alfa);

    domaindata.row1.alfa = 360/domaindata.row1.bld;
    domaindata.row1.area = get_circ_anulus_area(domaindata.row1.rmin, domaindata.row1.rmax, domaindata.row1.alfa);

    domaindata.row3.alfa = 360/domaindata.row3.bld;
    domaindata.row3.area = get_circ_anulus_area(domaindata.row3.rmin, domaindata.row3.rmax, domaindata.row3.alfa);
    
    domaindata.row2.alfa = 360/domaindata.row2.bld;
    domaindata.row2.area = get_circ_anulus_area(domaindata.row2.rmin, domaindata.row2.rmax, domaindata.row2.alfa);
    
    %Converting to XSteam units    
    p0 = double(domaindata.medium.p0*Pa_to_Bar)
    T0 = domaindata.medium.T0+Kelvin_to_Celsius;
    p2 = domaindata.medium.p2*Pa_to_Bar;
    
    %Inlet state parameters
    s0 = XSteam('s_pt',p0,T0);
    vol0 = XSteam('v_ps',p0,s0);
    x0 = XSteam('x_ps',p0,s0);
    rho0 = XSteam('rho_ps',p0,s0);
        
    if isnan(rho0)
        disp('Wet steam! Temperature is not right for this region!');        
        domaindata.medium.rho0 = XSteam('rho_ph',p0,domaindata.medium.h0);
        Cp0 = XSteam('Cp_ph',p0,domaindata.medium.h0); 
        if isnan(Cp0)
            domaindata.medium.Cp0 = domaindata.medium.h0*Kg_to_base/domaindata.medium.T0;
        else
            domaindata.medium.Cp0 = Cp0;
        end
        retVal = domaindata;
        return
    end
    
    domaindata.medium.rho0 = XSteam('rho_pT',p0,T0);
    domaindata.medium.vol0 = XSteam('v_pT',p0,T0);
    %domaindata.medium.h0 = XSteam('h_pT',p0,T0);
    %domaindata.medium.s0 = XSteam('s_pT',p0,T0);
    %domaindata.medium.Cp0 = XSteam('Cp_pT',p0,T0);
    
    domaindata.medium.Rconst0 = domaindata.medium.p0/(domaindata.medium.rho0*domaindata.medium.T0);
    
    %Outlet state parameters
    domaindata.medium.h2 = XSteam('h_ps',domaindata.medium.p2*Pa_to_Bar,domaindata.medium.s0);
    domaindata.medium.T2 = XSteam('T_ph',domaindata.medium.p2*Pa_to_Bar,domaindata.medium.h2)+Celsius_to_Kelvin;
    
    domaindata.medium.s0 = domaindata.medium.s0*Celsius_to_Kelvin;
    domaindata.medium.h2 = domaindata.medium.h2*Celsius_to_Kelvin;        
    
    domaindata.medium.rho2 = XSteam('rho_pT',domaindata.medium.p2*Pa_to_Bar,domaindata.medium.T2+Kelvin_to_Celsius);
    domaindata.medium.vol2 = XSteam('v_pT',domaindata.medium.p2*Pa_to_Bar,domaindata.medium.T2+Kelvin_to_Celsius);
    
    domaindata.medium.Cp2 = XSteam('Cp_pT',domaindata.medium.p2*Pa_to_Bar,domaindata.medium.T2+Kelvin_to_Celsius);
    domaindata.medium.Rconst2 = domaindata.medium.p2/(domaindata.medium.rho2*domaindata.medium.T2);
    
    %Equivalent ideal gas parameters
    domaindata.medium.Cp_ig = ((domaindata.medium.h0 - domaindata.medium.h2)*Kg_to_base)/(domaindata.medium.T0 - domaindata.medium.T2);
    domaindata.medium.Rconst_ig = (domaindata.medium.Rconst0 + domaindata.medium.Rconst2)/2;
    domaindata.medium.Kappa_ig = 1/(1-(domaindata.medium.Rconst_ig/domaindata.medium.Cp_ig));
    %domaindata.rho0 = XSteam('rho_pT',domaindata.p0*Pa_to_Bar,domaindata.T0);
    
    retVal = domaindata;