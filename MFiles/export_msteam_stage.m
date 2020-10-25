function status = export_msteam_stage(stage,HUB_INOUT,SHROUD_INOUT,sectioncnt)
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
    
    NOZZL = STG.NZL;
    NOZZL.XYYR = [];
    NOZZL.LEIndex = [];
    NOZZL.TEIndex = [];
    NOZZL.betaOut = [];
    
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
    lc_inletoutlet = ones(size(lc_tt))*HUB(1,:)+lc_tt*(SHROUD(1,:)-HUB(1,:));
    lc_outlet = [NOZZL.XYYR(1,:,xcoord_id)',NOZZL.XYYR(1,:,radial_id)'];
    lc_CellSize = mean(NOZZL.XYYR(3,:,xcoord_id)-NOZZL.XYYR(2,:,xcoord_id));    

    HUB = [HUB; lc_outlet(1,:)];
    SHROUD = [SHROUD; lc_outlet(end,:)];
    %connect inlet and outlet part with blade - for nozzle
    lc_XYYR = createNonBladeDomain(HUB, SHROUD, lc_inletoutlet, 2*lc_CellSize, lc_outlet, lc_CellSize);
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

    lc_inletoutlet = [ NOZZL.XYYR(end,:,xcoord_id); NOZZL.XYYR(end,:,radial_id) ]';
    lc_inoutCellSize = mean(NOZZL.XYYR(end,:,xcoord_id)-NOZZL.XYYR(end-1,:,xcoord_id));

    lc_outlet = [ BUCKT.XYYR(1,:,xcoord_id); BUCKT.XYYR(1,:,radial_id) ]';
    lc_outCellSize = mean(BUCKT.XYYR(2,:,xcoord_id)-BUCKT.XYYR(1,:,xcoord_id));

    lc_XYYR = createNonBladeDomain(HUB, SHROUD, lc_inletoutlet, lc_inoutCellSize, lc_outlet, lc_outCellSize);
    [lc_XYYR_A, lc_XYYR_B] = splitDomain(lc_XYYR, SPLITCONST);


    %% NOZZLE DOMAIN - CONNECTION
    [NOZZL.XYYR, NOZZL.LEIndex, NOZZL.TEIndex] = connectDomain(NOZZL.XYYR, lc_XYYR_A, NOZZL.LEIndex, NOZZL.TEIndex);   
    
    %% BUCKET DOMAIN - CONNECTION
    [BUCKT.XYYR, BUCKT.LEIndex, BUCKT.TEIndex] = connectDomain(lc_XYYR_B, BUCKT.XYYR, BUCKT.LEIndex, BUCKT.TEIndex);
   
    %% BUCKET - OUTLET DOMAIN
    lc_tt = (0:1/(size(BUCKT.XYYR,2)-1):1)';
    lc_inlet = [BUCKT.XYYR(end,:,xcoord_id)',BUCKT.XYYR(end,:,radial_id)'];
    lc_outlet = ones(size(lc_tt))*HUB_INOUT(end,:)+lc_tt*(SHROUD_INOUT(end,:)-HUB_INOUT(end,:));
    
    lc_CellSize = mean(BUCKT.XYYR(end,:,xcoord_id)-BUCKT.XYYR(end-1,:,xcoord_id));   
    
    HUB = [ lc_inlet(1,:);
            lc_outlet(1,:) ];

    SHROUD = [ lc_inlet(end,:)
               lc_outlet(end,:) ];
           
    lc_XYYR = createNonBladeDomain(HUB, SHROUD, lc_inlet, lc_CellSize, lc_outlet, 2*lc_CellSize);

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
                    BUCKT.betaOut );
                
    clear INTERPROFILE lc_*;
    status = true;
    return;
end %export_msteam_onerow 