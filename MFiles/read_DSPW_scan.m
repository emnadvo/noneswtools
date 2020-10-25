function [ WholeBlade_dict, Source_dict ] = read_DSPW_scan()
% Function read data from scan provided by DSPW scan department and parse
% to dictionary form. 
% function return two parameters:
%   WholeBlade_dict - map container whith all profiles, profiles is
%                     structure which contain LE point and array with other points
%   Source_dict - map container with file content
%
    st_regex_LEP = 'LEP';
    delimiter = ';';
    comma = ',';
    point = '.';
    INDEX_ID = 2;
    msg = '';
    ANGLE_LIMIT = 0.2;
    
    Source_dict = containers.Map('KeyType','uint64','ValueType','any');
    WholeBlade_dict = containers.Map('KeyType','double','ValueType','any');

    curentdir = pwd;
    %startdir = 'C:\MinGW\msys\1.0\home\michal.nadvornik\Lopatka_MHI';
    %cd(startdir);
    startdir = pwd;

    %Find srcpath with files
    FilterSpec = {'*.asc'};
    [ FileName, PathName, FilterIndex ] = uigetfile(FilterSpec,'Choose your scan files','MultiSelect','on');

    if ischar(FileName) ~= 1 && iscell(FileName) ~= 1 && FileName == 0
        disp('Without file function does not work');
        return
    end

    %Case for one file
    if iscell(FileName)
        [rowsize, colsize] = size(FileName);
    elseif ischar(FileName) == 1
        colsize = 1
    end
    
    for i=1:colsize
        if ischar(FileName)
            data = importdata(strcat(PathName,FileName),delimiter);
            msg = FileName;
        elseif iscell(FileName)
            data = importdata(cell2mat(strcat(PathName,FileName(i))),delimiter);
            msg = cell2mat(FileName(i));
        else
            disp('Unknown type of filename! Which is wrong. Program finished');
            return
        end
        
        msg = sprintf('PROCESS FILE %s START',msg);
        disp(msg);
       
        Source_dict(i) = data;
        tempData = [];
       
        profile.LE = [];
        profile.LEdirectVect = [];
        profile.profilepoints = [];
        profile.index_LE = -1;
        profile.StartPointToLEpoint = [];
        profile.LEpointToEndPoint = [];
        profile.pnt_cnt = 0;
        profile.profileid = 0;
        profile.directVec = [];
        profile.directVecAngles = [];
        
        
        for j=1:size(data)
            line = strsplit(cell2mat(data(j)),delimiter);
            [lnrw, lncl] = size(line);
            
            if lncl ~= 4
                disp('strsplit returned bad result!')
                return
            else
                val1 = str2double(strrep(line(2),comma,point));
                val2 = str2double(strrep(line(3),comma,point));
                val3 = str2double(strrep(line(4),comma,point));
                
                if j == 1 %key into our map for recognize which profile it is
                    profile.profileid = str2double(strrep(line(INDEX_ID),comma,point));
                end
                
                if isempty(cell2mat(regexpi(line(1),st_regex_LEP))) ~= 1
                    profile.LE = [val1,...
                                  val2,...
                                  val3 ];
                    profile.LEdirectVect = [val1;val2];
                    
                else
                    tempData = [ tempData;...
                               [ val1,...
                                 val2,...
                                 val3 ] ];
                end
            end
        end
        %Find index of LE point
        %First locate close points
        nrmA = sqrt(tempData(:,1).^2+tempData(:,2).^2+tempData(:,3).^2);
        nrmB = sqrt(profile.LE(:,1).^2+profile.LE(:,2).^2+profile.LE(:,3).^2);

        Fi = acosd((tempData*profile.LE')./(nrmA*nrmB));
        indx_pnts = find(Fi<ANGLE_LIMIT);
        [r,c] = size(indx_pnts);

        %Second determine index of point close to LE point           
        searchindx = -1;
        if r == 1
            searchindx = indx_pnts;                
        %If is there more then one point then must be founded with minimal distance from LE point
        elseif r > 1
            closePoints = tempData(indx_pnts,:);
            minDist = 1e10;

            for k = 1:closePoints                    
                dist = sqrt((tempData(k,1) - LEpoints(1))^2+...
                            (tempData(k,2) - LEpoints(2))^2+...
                            (tempData(k,3) - LEpoints(3))^2 );
                if dist < minDist
                    minDist = dist;
                    searchindx = k;
                end
            end
        end

        if searchindx ~= -1
            %Fill all points to array include LE point on correct position
            profile.profilepoints = [tempData(1:searchindx-1,:);...
                                     profile.LE;
                                     tempData(searchindx:length(tempData),:)];
            profile.StartPointToLEpoint = [tempData(1:searchindx-1,:)]; %something like suction side
            profile.LEpointToEndPoint = [profile.LE; tempData(searchindx:length(tempData),:)]; %something like pressure side
            profile.index_LE = searchindx;
            
            %direction vectors calculation for point pi, pi+1, pi+2
            step = 1;
            if mod(length(profile.profilepoints),2) == 0
                step = 1;
            elseif mod(length(profile.profilepoints),3) == 0
            for k=1:step:(length(profile.profilepoints))
                first = profile.profilepoints(k,:);
                
                if k == (length(profile.profilepoints))
                    vec1 = profile.directVec(length(profile.directVec),:);
                    vec2 = profile.directVec(1,:);                    
                else
                    second = profile.profilepoints(k+1,:);
                    three = profile.profilepoints(k+2,:);
                    vec1 = [(second(:,1) - first(:,1)),...
                            (second(:,2) - first(:,2)),...
                            (second(:,3) - first(:,3)) ];

                    vec2 = [(three(:,1) - second(:,1)),...
                            (three(:,2) - second(:,2)),...
                            (three(:,3) - second(:,3)) ];

                    profile.directVec = [ profile.directVec; vec1; vec2];

                end
                
                nrmA = sqrt(vec1(:,1).^2+vec1(:,2).^2+vec1(:,3).^2);
                nrmB = sqrt(vec2(:,1).^2+vec2(:,2).^2+vec2(:,3).^2)';
                
                Fi = acosd((vec1*vec2')./(nrmA*nrmB'));
                profile.directVecAngles = [ profile.directVecAngles; Fi ];
            end

        else
            profile.profilepoints = tempData;
            profile.index_LE = -1;
        end
        
        profile.pnt_cnt = length(profile.profilepoints);
        WholeBlade_dict(profile.profileid) = profile;
    end
    cd(curentdir);
end


% delimiter = uicontrol('Style','popupmenu','String',';|\s|,|.','Callback',@setdelimiter);
% function outval = setdelimiter(hObj,event)    
%     outval = get(hObj,'String');
% end