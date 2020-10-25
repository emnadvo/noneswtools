function status = export_msteam_halfstg(stage,HUB_INOUT,SHROUD_INOUT,sectioncnt)
%
%  BastlMaster 333.3.6 (c) Všechna káva vypražena
%  22.7.2015 
%
%  Script for export stage geometry for MSteam into one and half stage form 
%
%   [in] stage - mat file name with whole stage, 
%   [in] HUB - matrix with hub point definition
%   [in] SHROUD - matrix with shroud point definition
%   [in] sectioncnt - count of section
%
%   [out] status - result value


    status = false;
    SECTION = NaN;
    BLDPOINTCNT = 60;
    SPLITCONST = 0.5;
    AXSHIFT = 0.0;
    DISTCOEF = 4;
    xcoord_id = 1;
    rphi_id = 2;
    deltarphi_id = 3;
    radial_id = 4;
    HSPARAM_RID = 1;
    HSPARAM_PHIID = 2;
    HSPARAM_XMINID = 3;
    HSPARAM_XMAXID = 4;
    TCHUB_ID = 1;
    TCSHRD_ID = 2;
    TCLIMIT = 1e-3;
    
    MSGWARNING_OUTTC = 'NEW T/C ARE TOO MUCH DIFFERENT THEN SOURCE BLADE HAVE!';
    
    
    % Test section
    if exist(stage) ~= 2
        disp('Without mfile with stage definition program does not work');
        return;
    elseif nargin <= 2
        disp('Without coordinates for global inlet and outlet of stage program does not work');
        return;
    elseif nargin < 4
        SECTION = 15;
    end
    
    if isnan(SECTION)
        SECTION = sectioncnt;
    end

    load(stage);
    if exist('STG') ~= 1
        disp('Variable STG missing in your mat file!');
        return
    end
    
    %local variable for execution    
    lc_scriptName = mfilename('fullpath');
    [lc_currentpath, ~, ~]= fileparts(lc_scriptName);
    FICTIVEBLADE = load(sprintf('%s%s%s',lc_currentpath,filesep,'SrcBlade\final_univerzal_Dp1390.mat'));    
    addpath(lc_currentpath);
    
    
    NOZZL = STG.NZL;
    NOZZL.XYYR = [];
    NOZZL.LEIndex = [];
    NOZZL.TEIndex = [];
    NOZZL.betaOut = [];
    
    FCTNOZZL = FICTIVEBLADE; %STG.NZL;
%     FCTNOZZL.XYYR = [];
%     FCTNOZZL.LEIndex = [];
%     FCTNOZZL.TEIndex = [];
%     FCTNOZZL.betaOut = [];
    
    BUCKT = STG.BCK;
    BUCKT.XYYR = [];
    BUCKT.LEIndex = [];
    BUCKT.TEIndex = [];
    BUCKT.betaOut = [];    
    
    
    [ NOZZL.XYYR, ...
      NOZZL.LEIndex, ...
      NOZZL.TEIndex, ...
      NOZZL.betaOut] = createBladeDomain( SECTION, ...
                                          NOZZL.rootDiameter, ...
                                          NOZZL.profParam, ...
                                          NOZZL.leadingPoint, ...
                                          NOZZL.hubParam, ...
                                          NOZZL.tipParam, ...
                                          NOZZL.LeanLimits, ...
                                          NOZZL.Lean, ...
                                          NOZZL.SweepLimits, ...
                                          NOZZL.Sweep, ...
                                          BLDPOINTCNT);
    % Transformation of blade - axial move and no mirror
    [ NOZZL.XYYR, NOZZL.betaOut] = transformDomain(NOZZL.XYYR, NOZZL.betaOut, NOZZL.axialCoor, false);

    HUB = [ HUB_INOUT(1,:) ];
%            NOZZL.axialCoor, NOZZL.hubParam(HSPARAM_RID) ];

    SHROUD = [  SHROUD_INOUT(1,:) ];
%                NOZZL.axialCoor+NOZZL.tipParam(HSPARAM_XMAXID), NOZZL.tipParam(HSPARAM_RID) ];
            
    %Inlet part of nozzle row
    lc_tt = (0:1/(size(NOZZL.XYYR,2)-1):1)';
    lc_inlet = ones(size(lc_tt))*HUB(1,:)+lc_tt*(SHROUD(1,:)-HUB(1,:));
    lc_outlet = [NOZZL.XYYR(1,:,xcoord_id)',NOZZL.XYYR(1,:,radial_id)'];
    lc_CellSize = mean(NOZZL.XYYR(3,:,xcoord_id)-NOZZL.XYYR(2,:,xcoord_id));    

    HUB = [HUB; lc_outlet(1,:)];
    SHROUD = [SHROUD; lc_outlet(end,:)];
    %connect inlet and outlet part with blade - for nozzle
    lc_XYYR = createNonBladeDomain(HUB, SHROUD, lc_inlet, 2*lc_CellSize, lc_outlet, lc_CellSize);
    [NOZZL.XYYR, NOZZL.LEIndex, NOZZL.TEIndex] = connectDomain(lc_XYYR, NOZZL.XYYR, NOZZL.LEIndex, NOZZL.TEIndex);

    %Bucket part
    [ BUCKT.XYYR, ...
      BUCKT.LEIndex, ...
      BUCKT.TEIndex, ...
      BUCKT.betaOut] = createBladeDomain( SECTION, ...
                                          BUCKT.rootDiameter, ...
                                          BUCKT.profParam, ...
                                          BUCKT.leadingPoint, ...
                                          BUCKT.hubParam, ...
                                          BUCKT.tipParam, ...
                                          BUCKT.LeanLimits, ...
                                          BUCKT.Lean, ...
                                          BUCKT.SweepLimits, ...
                                          BUCKT.Sweep, ...
                                          BLDPOINTCNT);    

    % Transformation of blade - axial move and mirror
    [ BUCKT.XYYR, BUCKT.betaOut] = transformDomain(BUCKT.XYYR, BUCKT.betaOut, BUCKT.axialCoor, true);
    
    %% NOZZLE - BUCKET DOMAIN & SPLIT
    HUB = [ NOZZL.XYYR(end,1,xcoord_id), NOZZL.XYYR(end,1,radial_id)
            BUCKT.XYYR(1,1,xcoord_id), BUCKT.XYYR(1,1,radial_id) ];

    SHROUD = [  NOZZL.XYYR(end,end,xcoord_id), NOZZL.XYYR(end,end,radial_id)
                BUCKT.XYYR(1,end,xcoord_id), BUCKT.XYYR(1,end,radial_id) ];

    lc_inlet = [ NOZZL.XYYR(end,:,xcoord_id); NOZZL.XYYR(end,:,radial_id) ]';
    lc_inCellSize = mean(NOZZL.XYYR(end,:,xcoord_id)-NOZZL.XYYR(end-1,:,xcoord_id));

    lc_outlet = [ BUCKT.XYYR(1,:,xcoord_id); BUCKT.XYYR(1,:,radial_id) ]';
    lc_outCellSize = mean(BUCKT.XYYR(2,:,xcoord_id)-BUCKT.XYYR(1,:,xcoord_id));

    lc_XYYR = createNonBladeDomain(HUB, SHROUD, lc_inlet, lc_inCellSize, lc_outlet, lc_outCellSize);
    [lc_XYYR_A, lc_XYYR_B] = splitDomain(lc_XYYR, SPLITCONST);


    %% NOZZLE DOMAIN - CONNECTION
    [NOZZL.XYYR, NOZZL.LEIndex, NOZZL.TEIndex] = connectDomain(NOZZL.XYYR, lc_XYYR_A, NOZZL.LEIndex, NOZZL.TEIndex);   
    
    %% BUCKET DOMAIN - CONNECTION
    [BUCKT.XYYR, BUCKT.LEIndex, BUCKT.TEIndex] = connectDomain(lc_XYYR_B, BUCKT.XYYR, BUCKT.LEIndex, BUCKT.TEIndex);

    %% fictive nozzle (!! nulove kuzele pata) DODELAT ENDWALLS NOT INTERSECT   

    %Determine fictive blade
    lc_Fict_tc_const = (pi*(FCTNOZZL.hubDiameter+2*FCTNOZZL.sParameters(1,:)))./FCTNOZZL.bladeCount./FCTNOZZL.sParameters(2,:);
    
    %Determine axial width of tip for fictive blade
    [~, lc_ZP, lc_KeyPoints] = get_poly(FCTNOZZL.sParameters(:,2), FCTNOZZL.sLeadingPoint(:,2));
    [lc_E, ~] = profile_extr(lc_ZP, lc_KeyPoints);
    
    %Some important values for fictive blade
    lc_Fict_axLength = lc_E(2)-lc_E(1); %this calculate axial width of fictive blade at tip section
    %lc_Fict_axLength = lc_Fict_axLength + AXSHIFT*lc_Fict_axLength; %and append half of tip profile width
    lc_buck_maxAx_hub = BUCKT.axialCoor+BUCKT.hubParam(HSPARAM_XMAXID);
    lc_buck_maxAx_tip = BUCKT.axialCoor+BUCKT.tipParam(HSPARAM_XMAXID);
    
    lc_axialCoord = [ceil(lc_buck_maxAx_hub+(HUB_INOUT(end,1)-lc_buck_maxAx_hub)+lc_Fict_axLength)
                     ceil(lc_buck_maxAx_tip+(SHROUD_INOUT(end,1)-lc_buck_maxAx_tip)+lc_Fict_axLength)];
                 
    %lc_dist =max(lc_axialCoord-BUCKT.axialCoor);
    lc_dist =(max(lc_axialCoord)-(BUCKT.axialCoor+[ BUCKT.hubParam(HSPARAM_XMAXID);BUCKT.tipParam(HSPARAM_XMAXID) ]));
    %Stage outlet domain - tip
    lc_delta_r_buck_tip = BUCKT.tipParam(HSPARAM_XMAXID)*tand(BUCKT.tipParam(HSPARAM_PHIID));
    lc_delta_r_out = SHROUD_INOUT(end,2) - (BUCKT.tipParam(HSPARAM_RID)+lc_delta_r_buck_tip);
    
    lc_tip_outlet_phi = atand(lc_delta_r_out/(SHROUD_INOUT(end,1)-lc_buck_maxAx_tip));
    
    %Stage outlet domain - hub
    lc_delta_r_buck_hub = BUCKT.hubParam(HSPARAM_XMAXID)*tand(BUCKT.hubParam(HSPARAM_PHIID));
    lc_delta_r_out = HUB_INOUT(end,2) - (BUCKT.hubParam(HSPARAM_RID)+lc_delta_r_buck_hub);
    
    lc_hub_outlet_phi = atand(lc_delta_r_out/(HUB_INOUT(end,1)-lc_buck_maxAx_hub));
           
    lc_Radius = [((BUCKT.hubParam(HSPARAM_RID)+lc_delta_r_buck_hub)+lc_dist(1)*tand(lc_hub_outlet_phi))
                 ((BUCKT.tipParam(HSPARAM_RID)+lc_delta_r_buck_tip)+lc_dist(2)*tand(lc_tip_outlet_phi))]; %+lc_delta_r_buck_tip

%     lc_Radius = [(HUB_INOUT(end,2)+(max(lc_axialCoord)-HUB_INOUT(end,1))*tand(lc_hub_outlet_phi))
%                  (SHROUD_INOUT(end,2)+(max(lc_axialCoord)-SHROUD_INOUT(end,1))*tand(lc_tip_outlet_phi))]; %+lc_delta_r_buck_tip             
             
    lc_diameter_scale = ((2*lc_Radius(1))/FCTNOZZL.hubDiameter);
    lc_new_Fict_NBlades = ceil((pi*lc_Radius(1)*2)/(FCTNOZZL.sParameters(2,1)*lc_Fict_tc_const(TCHUB_ID)*lc_diameter_scale));
    lc_new_t = (pi*2*lc_Radius)./lc_new_Fict_NBlades;
    lc_new_c = lc_new_t./lc_Fict_tc_const';
    
    chordScale = lc_new_c'./FCTNOZZL.sParameters(2,:);

    FCTNOZZL.axialCoor = max(lc_axialCoord); %;
    FCTNOZZL.hubDiameter = 2*lc_Radius(1);
    FCTNOZZL.bladeCount = lc_new_Fict_NBlades;
    FCTNOZZL.sParameters(2,:) = lc_new_c;
    FCTNOZZL.sParameters(1,:) = lc_Radius - FCTNOZZL.hubDiameter/2;

    [~, lc_ZP, lc_KeyPoints] = get_poly(FCTNOZZL.sParameters(:,1), FCTNOZZL.sLeadingPoint(:,1));
    [lc_E, ~] = profile_extr(lc_ZP, lc_KeyPoints);
    lc_Fict_axLength = lc_E(2)-lc_E(1);
    
    FCTNOZZL.hubParam = [ lc_Radius(1)+(lc_Fict_axLength*tand(lc_hub_outlet_phi));
                          lc_hub_outlet_phi;%BUCKT.hubParam(HSPARAM_PHIID); % force change to zero angle at hub
                          NOZZL.hubParam(HSPARAM_XMINID)*max(chordScale) %floor(lc_hubRadius/BUCKT.hubParam(HSPARAM_RID)*FCTNOZZL.hubParam(HSPARAM_XMINID));
                          NOZZL.hubParam(HSPARAM_XMAXID) ];

    %For shroud with angle it's important to get highest radius     
    FCTNOZZL.shroudParam = [ lc_Radius(2);
                             lc_tip_outlet_phi; %BUCKT.tipParam(HSPARAM_PHIID);   % force change to zero angle at shroud
                             NOZZL.tipParam(HSPARAM_XMINID)*max(chordScale) %floor(lc_shroudRadius/BUCKT.tipParam(HSPARAM_RID)*FCTNOZZL.shroudParam(HSPARAM_XMINID));
                             NOZZL.tipParam(HSPARAM_XMAXID) ];

    %Scaling profiles
    lc_nLength = FCTNOZZL.shroudParam(HSPARAM_RID)-lc_Radius(1)+1;

    %Profiles interpolate
    lc_targetHeights = (0:lc_nLength/(size(NOZZL.profParam,2)-1):lc_nLength);
    INTERPROFILE = profile_interp(FCTNOZZL.sParameters,lc_targetHeights);
    FCTNOZZL.sParameters = INTERPROFILE;

    lc_new_fict_tc = (pi*(FCTNOZZL.hubDiameter+2*FCTNOZZL.sParameters(1,:)))./FCTNOZZL.bladeCount./FCTNOZZL.sParameters(2,:);
    assert(abs(lc_new_fict_tc(1)-lc_Fict_tc_const(1))<TCLIMIT && abs(lc_new_fict_tc(end)-lc_Fict_tc_const(2))<TCLIMIT,MSGWARNING_OUTTC);
    %disp(lc_new_fict_tc');
    
     FCTNOZZL.sLeadingPoint = get_nbcoor(FCTNOZZL.sParameters, FCTNOZZL.stackingPoint);

    [ FCTNOZZL.XYYR, ...
      FCTNOZZL.LEIndex, ...
      FCTNOZZL.TEIndex, ...
      FCTNOZZL.betaOut] = createBladeDomain(  SECTION, ...
                                              FCTNOZZL.hubDiameter, ...
                                              FCTNOZZL.sParameters, ...
                                              FCTNOZZL.sLeadingPoint, ...
                                              FCTNOZZL.hubParam, ...
                                              FCTNOZZL.shroudParam, ...
                                              FCTNOZZL.LEAN_LIMITS, ...
                                              FCTNOZZL.LEAN, ...
                                              FCTNOZZL.SWEEP_LIMITS, ...
                                              FCTNOZZL.SWEEP, ...
                                              BLDPOINTCNT); 
    
    [FCTNOZZL.XYYR, FCTNOZZL.betaOut] = transformDomain(FCTNOZZL.XYYR, FCTNOZZL.betaOut, FCTNOZZL.axialCoor, false);

    %% FICTIVE NOZZLE OUTLET
    lc_outX = ceil(FCTNOZZL.XYYR(end,1,xcoord_id)+0.25*(FCTNOZZL.XYYR(end,end,radial_id)-FCTNOZZL.XYYR(end,1,radial_id)));
    lc_hAngle = FCTNOZZL.hubParam(2);
    HUB = [ FCTNOZZL.XYYR(end,1,xcoord_id), FCTNOZZL.XYYR(end,1,radial_id)
            lc_outX, FCTNOZZL.XYYR(end,1,radial_id)+(lc_outX-FCTNOZZL.XYYR(end,1,xcoord_id))*tand(lc_hAngle) ];

    lc_shAngle = FCTNOZZL.shroudParam(2);
    SHROUD = [ FCTNOZZL.XYYR(end,end,xcoord_id), FCTNOZZL.XYYR(end,end,radial_id)
               lc_outX, FCTNOZZL.XYYR(end,end,radial_id)+(lc_outX-FCTNOZZL.XYYR(end,end,xcoord_id))*tand(lc_shAngle) ];

    lc_inlet = [FCTNOZZL.XYYR(end,:,xcoord_id)',FCTNOZZL.XYYR(end,:,radial_id)'];
    lc_inCellSize = mean(FCTNOZZL.XYYR(end,:,xcoord_id)-FCTNOZZL.XYYR(end-1,:,xcoord_id));
    tt = (0:1/(size(FCTNOZZL.XYYR,2)-1):1)';
    lc_outlet = ones(size(tt))*HUB(end,:)+tt*(SHROUD(end,:)-HUB(end,:));
        
    lc_XYYR = createNonBladeDomain(HUB, SHROUD, lc_inlet, lc_inCellSize, lc_outlet, 2*lc_inCellSize);

    %% FICTIVE NOZZLE OUTLET CONNECTION
    [FCTNOZZL.XYYR, FCTNOZZL.LEIndex, FCTNOZZL.TEIndex] = connectDomain(FCTNOZZL.XYYR, lc_XYYR, FCTNOZZL.LEIndex, FCTNOZZL.TEIndex);
    
    %% BUCKET - FICTIVE NOZZLE DOMAIN & SPLIT
    HUB = [ BUCKT.XYYR(end,1,xcoord_id), BUCKT.XYYR(end,1,radial_id)
            FCTNOZZL.XYYR(1,1,xcoord_id), FCTNOZZL.XYYR(1,1,radial_id) ];

    SHROUD = [ BUCKT.XYYR(end,end,xcoord_id), BUCKT.XYYR(end,end,radial_id)
               FCTNOZZL.XYYR(1,end,xcoord_id), FCTNOZZL.XYYR(1,end,radial_id) ];

    lc_inlet = [ BUCKT.XYYR(end,:,xcoord_id); BUCKT.XYYR(end,:,radial_id) ]';
    lc_inCellSize = mean(BUCKT.XYYR(end,:,xcoord_id)-BUCKT.XYYR(end-1,:,xcoord_id));

    lc_outlet = [ FCTNOZZL.XYYR(1,:,xcoord_id); FCTNOZZL.XYYR(1,:,radial_id) ]';
    lc_outCellSize = mean(FCTNOZZL.XYYR(2,:,xcoord_id)-FCTNOZZL.XYYR(1,:,xcoord_id));

    lc_XYYR = createNonBladeDomain(HUB, SHROUD, lc_inlet, lc_inCellSize, lc_outlet, lc_outCellSize);

    %% BUCKET - FICTIVE NOZZLE DOMAIN - CONNECTION
    [BUCKT.XYYR, BUCKT.LEIndex, BUCKT.TEIndex] = connectDomain(BUCKT.XYYR, lc_XYYR, BUCKT.LEIndex, BUCKT.TEIndex);

    [lc_currentpath, lc_filename, ~]= fileparts(stage);
    lc_outfilename = sprintf('%s%s%s.%s',lc_currentpath,filesep,lc_filename,'geomMsteam');
    
    %% VISUALIZATION
    outHnd = figure;
    hold on; grid on; axis equal;
    set(gcf,'Renderer','zbuffer');

    visualizeDomain(NOZZL.XYYR,[1,0,0]);
    visualizeDomain(BUCKT.XYYR,[0,0,1]);
    visualizeDomain(FCTNOZZL.XYYR,[0,0.7,0]);
    
    print(outHnd,'-djpeg',sprintf('%s%s%s.%s',lc_currentpath,filesep,lc_filename,'jpeg'));
    savefig(outHnd,sprintf('%s%s%s.%s',lc_currentpath,filesep,lc_filename,'fig'));
    
    %% EXPORT
    msteam_export(  lc_outfilename, ...
                    NOZZL.bladeCount, ...
                    NOZZL.XYYR, ...
                    NOZZL.LEIndex, ...
                    NOZZL.TEIndex, ...
                    NOZZL.betaOut, ...
                    BUCKT.bladeCount, ...
                    BUCKT.XYYR, ...
                    BUCKT.LEIndex, ...
                    BUCKT.TEIndex, ...
                    BUCKT.betaOut, ...
                    FCTNOZZL.bladeCount, ...
                    FCTNOZZL.XYYR, ...
                    FCTNOZZL.LEIndex, ...
                    FCTNOZZL.TEIndex, ...
                    FCTNOZZL.betaOut  );
                
    clear INTERPROFILE lc_*;
    status = true;
    return;
end %export_msteam_halfstg







































