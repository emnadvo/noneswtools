function retVal = get_profil_work(inMisesDir)
%
%  BastlMaster 333.3.6 (c) Všechna káva vypražena
%  22.7.2015 
%
%  Script for isoentropic Mach subtraction between suction and pressure
%  for profile work evaluate
%
%   [in] inMisesDir - directrory with Mises output file out.bmm
%   [out] retVal - result value
     
    if exist(inMisesDir) == 7
       MisesDir = inMisesDir;
    else
       disp('Mised directory is invalid!');        
       MisesDir = 'C:\bin\BladeMaster_3.4.0\opt';
       disp(sprintf('Program use default value %s',MisesDir));
    end 
    
    retVal = NaN;
    ErrMsg = 'Exception raised inside function get_profil_work()!';
    ME = MException('MISES:ProfileWork', ErrMsg);
    lc_polyline_ratio=10;
    LOWLIMIT = -1e-28;
    HIGHLIMIT = 1;
    NPOINTS = 150;
    SSMach_integr = 0;
    PSMach_integr = 0;
    
    lc_currentpath='C:\Data\doosanskodapower\BLM\trunk\lib_mises';
    addpath(lc_currentpath);

    fileDelete = false;
    
    [ stat, ...
      IprintData, ...
      mProfile, ...
      mBLayerSS, ...
      mBLayerPS, ...
      mMachSS, ...
      mMachPS ] = mises_post(MisesDir, fileDelete);
  
%     figure;hold on;
    
  
    if length(mMachSS)>0 && length(mMachPS)>0
        lc_intrvA = (0:HIGHLIMIT/NPOINTS:HIGHLIMIT);
        %get values from 0 to 1 only
        filtr_MachSS = mMachSS(find(mMachSS(:,1)>= LOWLIMIT & mMachSS(:,1)<= HIGHLIMIT),:);
        if length(filtr_MachSS)>0            
            lc_intrvB = spline(filtr_MachSS(:,1),filtr_MachSS(:,2),lc_intrvA);
            SSMach_integr = trapz(lc_intrvA,lc_intrvB);
%             plot(lc_intrvA,lc_intrvB,'.b');
        else
            rethrow(ME);
        end
        
        filtr_MachPS = mMachPS(find(mMachPS(:,1)>= LOWLIMIT & mMachPS(:,1)<= HIGHLIMIT),:);
        if length(filtr_MachSS)>0            
            lc_intrvB = spline(filtr_MachPS(:,1),filtr_MachPS(:,2),lc_intrvA);
            PSMach_integr = trapz(lc_intrvA,lc_intrvB);
%             plot(lc_intrvA,lc_intrvB,'.r');
        else
            rethrow(ME);
        end
    
    end
    
%         PSMach_integr
%         SSMach_integr
    
    retVal = SSMach_integr-PSMach_integr;
    return;
    
end %get_profil_work
  
  









