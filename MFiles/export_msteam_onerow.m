function status = export_msteam_onerow(row_mat,sectioncnt)
%
%  BastlMaster 333.3.6 (c) Všechna káva vypražena
%  22.7.2015 
%
%  Script for export stage geometry for MSteam into one and half stage form 
%
%   [in] row mat - mat file name with whole stage, 
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
    UPSTREAM_LENGTH = 0.5;
    DOWNSTREAM_LENGTH = 0.75;
    
    MSGWARNING_OUTTC = 'NEW T/C ARE TOO MUCH DIFFERENT THEN SOURCE BLADE HAVE!';
    
    
    % Test section
    if exist(row_mat) ~= 2
        disp('Without mfile with stage definition program does not work');
        return;
    elseif nargin < 2
        SECTION = 15;
    end
    
    if isnan(SECTION)
        SECTION = sectioncnt;
    end
    
    ROW=load(row_mat);
    if exist('ROW') ~= 1
        disp('Variable ROW missing in your mat file!');
        return
    end
    
    %local variable for execution    
    lc_scriptName = mfilename('fullpath');
    [lc_currentpath, ~, ~]= fileparts(lc_scriptName);
    addpath(lc_currentpath);
    
    NOZZL = ROW;
    NOZZL.XYYR = [];
    NOZZL.LEIndex = [];
    NOZZL.TEIndex = [];
    NOZZL.betaOut = [];
    NOZZL.axialCoor = NaN;
    
    lc_bldlength =NOZZL.shroudParam(HSPARAM_RID) - (NOZZL.hubDiameter/2);
    
    %Correction of section count
    lc_actrowsection = size(NOZZL.sParameters,2);
    if lc_actrowsection ~= SECTION        
        %Profiles interpolate
        lc_targetHeights = (0:lc_bldlength/(SECTION-1):lc_bldlength);
        INTERPROFILE = profile_interp(NOZZL.sParameters,lc_targetHeights);
        NOZZL.sParameters = INTERPROFILE;
        NOZZL.sLeadingPoint = get_nbcoor(NOZZL.sParameters, NOZZL.stackingPoint);
    end
    
    NOZZL.axialCoor = 0.0;
    
    [ NOZZL.XYYR, ...
      NOZZL.LEIndex, ...
      NOZZL.TEIndex, ...
      NOZZL.betaOut] = createBladeDomain( SECTION, ...
                                          NOZZL.hubDiameter, ...
                                          NOZZL.sParameters, ...
                                          NOZZL.sLeadingPoint, ...
                                          NOZZL.hubParam, ...
                                          NOZZL.shroudParam, ...
                                          NOZZL.LEAN_LIMITS, ...
                                          NOZZL.LEAN, ...
                                          NOZZL.SWEEP_LIMITS, ...
                                          NOZZL.SWEEP, ...
                                          BLDPOINTCNT);
    % Transformation of blade - axial move and no mirror
    [ NOZZL.XYYR, NOZZL.betaOut] = transformDomain(NOZZL.XYYR, NOZZL.betaOut, NOZZL.axialCoor, false);
    
    lc_inlet_xcoord = NOZZL.hubParam(HSPARAM_XMINID)-lc_bldlength*UPSTREAM_LENGTH;

    lc_Radius = [(NOZZL.hubParam(HSPARAM_RID)-lc_inlet_xcoord*tand(NOZZL.hubParam(HSPARAM_PHIID)))
                 (NOZZL.shroudParam(HSPARAM_RID)-lc_inlet_xcoord*tand(NOZZL.shroudParam(HSPARAM_PHIID)))];    
        
    HUB = [ lc_inlet_xcoord, lc_Radius(1);
            ];
    SHROUD = [ lc_inlet_xcoord, lc_Radius(2) ];
            
    %Inlet part of nozzle row
    lc_tt = (0:1/(size(NOZZL.XYYR,2)-1):1)';
    lc_inlet = ones(size(lc_tt))*HUB(1,:)+lc_tt*(SHROUD(1,:)-HUB(1,:));
    lc_outlet = [NOZZL.XYYR(1,:,xcoord_id)',NOZZL.XYYR(1,:,radial_id)'];
    lc_CellSize = abs(mean(NOZZL.XYYR(3,:,xcoord_id)-NOZZL.XYYR(2,:,xcoord_id)));    

    HUB = [HUB; lc_outlet(1,:)];
    SHROUD = [SHROUD; lc_outlet(end,:)];
    %connect inlet and outlet part with blade - for nozzle
    lc_XYYR = createNonBladeDomain(HUB, SHROUD, lc_inlet, 2*lc_CellSize, lc_outlet, lc_CellSize);
    [NOZZL.XYYR, NOZZL.LEIndex, NOZZL.TEIndex] = connectDomain(lc_XYYR, NOZZL.XYYR, NOZZL.LEIndex, NOZZL.TEIndex);   
    
    %% NOZZLE DOMAIN OUTLET
    lc_outlet_xcoord = NOZZL.hubParam(HSPARAM_XMAXID)+lc_bldlength*DOWNSTREAM_LENGTH;
    lc_hAngle = NOZZL.hubParam(2);
    
    HUB = [ NOZZL.XYYR(end,1,xcoord_id), NOZZL.XYYR(end,1,radial_id)
            lc_outlet_xcoord, NOZZL.XYYR(end,1,radial_id)+(lc_outlet_xcoord-NOZZL.XYYR(end,1,xcoord_id))*tand(lc_hAngle) ];

    lc_shAngle = NOZZL.shroudParam(2);
    SHROUD = [ NOZZL.XYYR(end,end,xcoord_id), NOZZL.XYYR(end,end,radial_id)
               lc_outlet_xcoord, NOZZL.XYYR(end,end,radial_id)+(lc_outlet_xcoord-NOZZL.XYYR(end,end,xcoord_id))*tand(lc_shAngle) ];

    lc_inlet = [ NOZZL.XYYR(end,:,xcoord_id); NOZZL.XYYR(end,:,radial_id) ]';
    lc_inCellSize = abs(mean(NOZZL.XYYR(end,:,xcoord_id)-NOZZL.XYYR(end-1,:,xcoord_id)));
    
    tt = (0:1/(size(NOZZL.XYYR,2)-1):1)';
    lc_outlet = ones(size(tt))*HUB(end,:)+tt*(SHROUD(end,:)-HUB(end,:));
    lc_outCellSize = abs(mean(NOZZL.XYYR(2,:,xcoord_id)-NOZZL.XYYR(1,:,xcoord_id)));
    
    lc_XYYR = createNonBladeDomain(HUB, SHROUD, lc_inlet, lc_inCellSize, lc_outlet, lc_outCellSize);

    %% NOZZLE DOMAIN - CONNECTION
    [NOZZL.XYYR, NOZZL.LEIndex, NOZZL.TEIndex] = connectDomain(NOZZL.XYYR, lc_XYYR, NOZZL.LEIndex, NOZZL.TEIndex);
    [lc_currentpath, lc_filename, ~]= fileparts(row_mat);
    lc_outfilename = sprintf('%s%s%s.%s',lc_currentpath,filesep,lc_filename,'geomMsteam');
    
    %% VISUALIZATION
    outHnd = figure;
    hold on; grid on; axis equal;
    set(gcf,'Renderer','zbuffer');

    visualizeDomain(NOZZL.XYYR,[1,0,0]);
    
    print(outHnd,'-djpeg',sprintf('%s%s%s.%s',lc_currentpath,filesep,lc_filename,'jpeg'));
    savefig(outHnd,sprintf('%s%s%s.%s',lc_currentpath,filesep,lc_filename,'fig'));
    
    %% EXPORT
    msteam_export(  lc_outfilename, ...
                    NOZZL.bladeCount, ...
                    NOZZL.XYYR, ...
                    NOZZL.LEIndex, ...
                    NOZZL.TEIndex, ...
                    NOZZL.betaOut  );
                
    clear INTERPROFILE lc_*;
    status = true;
    return;
end %export_msteam_onerow 