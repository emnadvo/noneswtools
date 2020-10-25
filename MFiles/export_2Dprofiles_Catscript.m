function export_2Dprofiles_Catscript( Filename, ...
                                      Description,  ...
                                      XYZ2D, ...
                                      GIndex, ...
                                      LEPointCount, ...
                                      angle_max, ...
                                      angle_min )

%% FILE OPENING & BASIC DEFINITIONS
    fid = fopen(Filename,'w');

    fprintf(fid,'Language="VBSCRIPT"\n\n');
    fprintf(fid,'Sub CATMain()\n\n');
    
    fprintf(fid,'Dim partMainDocument As Document\n');
    fprintf(fid,'Set partMainDocument = CATIA.Documents.Add("Part")\n');
    fprintf(fid,'Set partMainDocument = CATIA.ActiveDocument\n\n');
    
    fprintf(fid,'Dim main_part As Part\n');
    fprintf(fid,'Set main_part = partMainDocument.Part\n\n');
    
    fprintf(fid,'Dim hybridShapeFactory As Factory\n');
    fprintf(fid,'Set hybridShapeFactory = main_part.HybridShapeFactory\n\n');
    
    fprintf(fid,'Dim XAxisReference As Reference \n');
    fprintf(fid,'Set XAxisReference = main_part.CreateReferenceFromBRepName("REdge:(Edge:(Face:(Brp:(AxisSystem.1;1);None:();Cf11:());Face:(Brp:(AxisSystem.1;3);None:();Cf11:());None:(Limits1:();Limits2:());Cf11:());WithPermanentBody;WithoutBuildError;WithSelectingFeatureSupport;MFBRepVersion_CXR15)", main_part.AxisSystems.Item("Absolute Axis System"))\n');


    %% TREE DEFINITIONS
    fprintf(fid,'Dim mainbody As Body\n');
    fprintf(fid,'Set mainbody = main_part.Bodies.Item("PartBody")\n');
    fprintf(fid,'mainbody.Name = "PROFILE"\n');
    fprintf(fid,'\n');

%     fprintf(fid,'Dim hybridBody_surf As HybridBody\n');
%     fprintf(fid,'Set hybridBody_surf = main_part.HybridBodies.Add()\n');
%     fprintf(fid,'hybridBody_surf.Name = "PROFILE_SURFACE_ELEMENTS"\n\n');
    
    
    %% PARAMETERS
    fprintf(fid,'Dim descr As StrParam \n');
    fprintf(fid,'Set descr = main_part.Parameters.CreateString("Description", "%s") \n',Description);
    fprintf(fid,'\n');
                             
    
    %% Curve
    if ~isempty(XYZ2D)
        % Profile points & spline segments
        for j = 1:size(XYZ2D,2)  %for each profile do
            
            fprintf(fid,'Dim hybridBody_curv%03d As HybridBody\n',j);
            fprintf(fid,'Set hybridBody_curv%03d = main_part.HybridBodies.Add()\n',j);
            fprintf(fid,'hybridBody_curv%03d.Name = "PROFILE_CURVES_%03d"\n\n',j,j);
    
            for i = 1:size(XYZ2D,1)
                fprintf(fid,'Dim pnt%03d%03d As HybridShapePointCoord\n',j,i);
                fprintf(fid,'Set pnt%03d%03d = hybridShapeFactory.AddNewPointCoord(%14.8f,%14.8f,%14.8f)\n\n',j,i,XYZ2D(i,j,1),XYZ2D(i,j,2),XYZ2D(i,j,3));
            end

            fprintf(fid,'Dim SplineA%03d As HybridShapeSpline\n',j);
            fprintf(fid,'Set SplineA%03d = hybridShapeFactory.AddNewSpline()\n',j);
            fprintf(fid,'SplineA%03d.SetSplineType 0\n',j);
            fprintf(fid,'SplineA%03d.SetClosing 0\n\n',j);
            for i = GIndex(1):GIndex(3)
                fprintf(fid,'SplineA%03d.AddPointWithConstraintExplicit pnt%03d%03d, Nothing, -1.000000, 1, Nothing, 0.000000\n',j,j,i);
            end    
            fprintf(fid,'\n');

            fprintf(fid,'Dim SplineTE%03d As HybridShapeSpline\n',j);
            fprintf(fid,'Set SplineTE%03d = hybridShapeFactory.AddNewSpline()\n',j);
            fprintf(fid,'SplineTE%03d.SetSplineType 0\n',j);
            fprintf(fid,'SplineTE%03d.SetClosing 0\n\n',j);
            fprintf(fid,'SplineTE%03d.AddPointWithConstraintFromCurve pnt%03d%03d, SplineA%03d, 1.000000, 1, 1\n',j,j,GIndex(3),j);
            for i = [GIndex(3)+1:size(XYZ2D,1),1:GIndex(1)-1]
                fprintf(fid,'SplineTE%03d.AddPointWithConstraintExplicit pnt%03d%03d, Nothing, -1.000000, 1, Nothing, 0.000000\n',j,j,i);
            end
            fprintf(fid,'SplineTE%03d.AddPointWithConstraintFromCurve pnt%03d%03d, SplineA%03d, 1.000000, 1, 1\n',j,j,GIndex(1),j);
            fprintf(fid,'\n');
            
            %Split spline_
            fprintf(fid,'Dim Split_SS%03d As HybridShapeSplit\n',j);
            fprintf(fid,'Set Split_SS%03d = hybridShapeFactory.AddNewHybridSplit(SplineA%03d, pnt%03d%03d, 1)\n',j,j,j,GIndex(2)-(LEPointCount-1)/2);
            fprintf(fid,'Dim Split_LEPS%03d As HybridShapeSplit\n',j);
            fprintf(fid,'Set Split_LEPS%03d = hybridShapeFactory.AddNewHybridSplit(SplineA%03d, pnt%03d%03d, -1)\n',j,j,j,GIndex(2)-(LEPointCount-1)/2);
            fprintf(fid,'Dim Split_LE%03d As HybridShapeSplit\n',j);
            fprintf(fid,'Set Split_LE%03d = hybridShapeFactory.AddNewHybridSplit(Split_LEPS%03d, pnt%03d%03d, 1)\n',j,j,j,GIndex(2)+(LEPointCount-1)/2);
            fprintf(fid,'Dim Split_PS%03d As HybridShapeSplit\n',j);
            fprintf(fid,'Set Split_PS%03d = hybridShapeFactory.AddNewHybridSplit(Split_LEPS%03d, pnt%03d%03d, -1)\n',j,j,j,GIndex(2)+(LEPointCount-1)/2);
            
            % Pressure side surface segment
            fprintf(fid,'Dim PSshape%03d As HybridShapeLoft\n',j);
            fprintf(fid,'Set PSshape%03d = hybridShapeFactory.AddNewLoft()\n',j);
            fprintf(fid,'PSshape%03d.Name = "PROFILE%03d_PRESSURE_SIDE"\n',j,j);
            fprintf(fid,'PSshape%03d.SectionCoupling = 1\n',j);
            fprintf(fid,'PSshape%03d.Relimitation = 1\n',j);
            fprintf(fid,'PSshape%03d.CanonicalDetection = 2\n\n',j);
            fprintf(fid,'PSshape%03d.AddSectionToLoft Split_PS%03d, 1, Nothing\n',j,j);
            fprintf(fid,'\n');
            fprintf(fid,'PSshape%03d.AddGuide SplineA%03d\n',j,j);
            fprintf(fid,'\n');
            fprintf(fid,'hybridBody_curv%03d.AppendHybridShape PSshape%03d\n\n',j,j);

            % Suction side surface segment
            fprintf(fid,'Dim SSshape%03d As HybridShapeLoft\n',j);
            fprintf(fid,'Set SSshape%03d = hybridShapeFactory.AddNewLoft()\n',j);
            fprintf(fid,'SSshape%03d.Name = "PROFILE%03d_LEADING_EDGE"\n',j,j);
            fprintf(fid,'SSshape%03d.SectionCoupling = 1\n',j);
            fprintf(fid,'SSshape%03d.Relimitation = 1\n',j);
            fprintf(fid,'SSshape%03d.CanonicalDetection = 2\n\n',j);
            fprintf(fid,'SSshape%03d.AddSectionToLoft Split_SS%03d, 1, Nothing\n',j,j);
            fprintf(fid,'\n');
            fprintf(fid,'SSshape%03d.AddGuide SplineA%03d\n',j,j);
            fprintf(fid,'\n');
            fprintf(fid,'hybridBody_curv%03d.AppendHybridShape SSshape%03d\n\n',j,j);
            
%             % LE side surface segment
%             fprintf(fid,'Dim LEshape%03d As HybridShapeLoft\n',j);
%             fprintf(fid,'Set LEshape%03d = hybridShapeFactory.AddNewLoft()\n',j);
%             fprintf(fid,'LEshape%03d.Name = "PROFILE%03d_TRAILING_EDGE"\n',j);
%             fprintf(fid,'LEshape%03d.SectionCoupling = 1\n',j);
%             fprintf(fid,'LEshape%03d.Relimitation = 1\n',j);
%             fprintf(fid,'LEshape%03d.CanonicalDetection = 2\n\n',j);
%             fprintf(fid,'LEshape%03d.AddSectionToLoft Split_SS%03d, 1, Nothing\n',j,j);
%             fprintf(fid,'\n');
%             fprintf(fid,'LEshape%03d.AddGuide SplineB%03d\n',j,j);
%             fprintf(fid,'\n');
%             fprintf(fid,'hybridBody_curv%03d.AppendHybridShape LEshape%03d\n\n',j);            
% 
%             % Trailing edge surface segment
%             fprintf(fid,'Dim TEshape As HybridShapeLoft\n');
%             fprintf(fid,'Set TEshape = hybridShapeFactory.AddNewLoft()\n');
%             fprintf(fid,'TEshape.Name = "TRAILING_EDGE"\n');
%             fprintf(fid,'TEshape.SectionCoupling = 1\n');
%             fprintf(fid,'TEshape.Relimitation = 1\n');
%             fprintf(fid,'TEshape.CanonicalDetection = 2\n\n');
%             for j = 1:size(XYZ2D,2)
%                 fprintf(fid,'TEshape.AddSectionToLoft SplineTE%03d, 1, Nothing\n',j);
%             end
%             fprintf(fid,'\n');
%             for i = [GIndex(3),GIndex(1)]
%                 fprintf(fid,'TEshape.AddGuide SplineB%03d\n',i);
%             end
%             fprintf(fid,'\n');
%             fprintf(fid,'hybridBody_surf.AppendHybridShape TEshape\n\n');
        end
        



% 

% 
%         % Suction side surface segment
%         fprintf(fid,'Dim SSshape As HybridShapeLoft\n');
%         fprintf(fid,'Set SSshape = hybridShapeFactory.AddNewLoft()\n');
%         fprintf(fid,'SSshape.Name = "SUCTION_SIDE"\n');
%         fprintf(fid,'SSshape.SectionCoupling = 1\n');
%         fprintf(fid,'SSshape.Relimitation = 1\n');
%         fprintf(fid,'SSshape.CanonicalDetection = 2\n\n');
%         for j = 1:size(XYZ2D,2)
%             fprintf(fid,'SSshape.AddSectionToLoft Split_SS%03d, 1, Nothing\n',j);
%         end
%         fprintf(fid,'\n');
%         for i = [GIndex(1),GIndex(2)-(LEPointCount-1)/2]
%             fprintf(fid,'SSshape.AddGuide SplineB%03d\n',i);
%         end
%         fprintf(fid,'\n');
%         fprintf(fid,'hybridBody_surf.AppendHybridShape SSshape\n\n');
% 
%         % Leading edge surface segment
%         fprintf(fid,'Dim LEshape As HybridShapeLoft\n');
%         fprintf(fid,'Set LEshape = hybridShapeFactory.AddNewLoft()\n');
%         fprintf(fid,'LEshape.Name = "LEADING_EDGE"\n');
%         fprintf(fid,'LEshape.SectionCoupling = 1\n');
%         fprintf(fid,'LEshape.Relimitation = 1\n');
%         fprintf(fid,'LEshape.CanonicalDetection = 2\n\n');
%         for j = 1:size(XYZ2D,2)
%             fprintf(fid,'LEshape.AddSectionToLoft Split_LE%03d, 1, Nothing\n',j);
%         end
%         fprintf(fid,'\n');
%         for i = [GIndex(2)-(LEPointCount-1)/2,GIndex(2)+(LEPointCount-1)/2]
%             fprintf(fid,'LEshape.AddGuide SplineB%03d\n',i);
%         end
%         fprintf(fid,'\n');
%         fprintf(fid,'hybridBody_surf.AppendHybridShape LEshape\n\n');
% 
%         % Pressure side surface segment
%         fprintf(fid,'Dim PSshape As HybridShapeLoft\n');
%         fprintf(fid,'Set PSshape = hybridShapeFactory.AddNewLoft()\n');
%         fprintf(fid,'PSshape.Name = "PRESSURE_SIDE"\n');
%         fprintf(fid,'PSshape.SectionCoupling = 1\n');
%         fprintf(fid,'PSshape.Relimitation = 1\n');
%         fprintf(fid,'PSshape.CanonicalDetection = 2\n\n');
%         for j = 1:size(XYZ2D,2)
%             fprintf(fid,'PSshape.AddSectionToLoft Split_PS%03d, 1, Nothing\n',j);
%         end
%         fprintf(fid,'\n');
%         for i = [GIndex(2)+(LEPointCount-1)/2,GIndex(3)]
%             fprintf(fid,'PSshape.AddGuide SplineB%03d\n',i);
%         end
%         fprintf(fid,'\n');
%         fprintf(fid,'hybridBody_surf.AppendHybridShape PSshape\n\n');

        % Flow surface join
%         fprintf(fid,'Dim BladeSurfaceAssemble1 As HybridShapeAssemble \n');
%         fprintf(fid,'Set BladeSurfaceAssemble1 = hybridShapeFactory.AddNewJoin(TEshape, SSshape)\n');
%         fprintf(fid,'BladeSurfaceAssemble1.AddElement LEshape\n');
%         fprintf(fid,'BladeSurfaceAssemble1.AddElement PSshape\n');
%         fprintf(fid,'BladeSurfaceAssemble1.SetConnex 1\n');
%         fprintf(fid,'BladeSurfaceAssemble1.SetManifold 0\n');
%         fprintf(fid,'BladeSurfaceAssemble1.SetSimplify 0\n');
%         fprintf(fid,'BladeSurfaceAssemble1.SetSuppressMode 0\n');
%         fprintf(fid,'BladeSurfaceAssemble1.SetDeviation 0.001000\n');
%         fprintf(fid,'BladeSurfaceAssemble1.SetAngularToleranceMode 0\n');
%         fprintf(fid,'BladeSurfaceAssemble1.SetAngularTolerance 0.500000\n');
%         fprintf(fid,'BladeSurfaceAssemble1.SetFederationPropagation 0\n');
%         fprintf(fid,'BladeSurfaceAssemble1.Name = "FLOW_SURFACE_JOIN"\n');
%         fprintf(fid,'\n');
%         fprintf(fid,'hybridBody_surf.AppendHybridShape BladeSurfaceAssemble1\n\n');
        
        
        % View settings
        fprintf(fid,'Dim specsAndGeomWindow1 As Window\n');
        fprintf(fid,'Set specsAndGeomWindow1 = CATIA.ActiveWindow\n');
        fprintf(fid,'Dim viewer3D1 As Viewer\n');
        fprintf(fid,'Set viewer3D1 = specsAndGeomWindow1.ActiveViewer\n');
        fprintf(fid,'viewer3D1.Reframe\n');
        fprintf(fid,'Dim viewpoint3D1 As Viewpoint3D\n');
        fprintf(fid,'Set viewpoint3D1 = viewer3D1.Viewpoint3D\n\n');

        % Saving
        [~, name] = fileparts(Filename);
        fprintf(fid,'partMainDocument.SaveAs ".\\%s.CATPart"\n\n',name);

        fprintf(fid,'End Sub\n');
        
    else
        disp('Your source points are empty!');
    end
    
end