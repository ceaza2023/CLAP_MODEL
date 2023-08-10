function [j2for_out,i2for_out, j2for,i2for,j2,i2]=locate_runoff(dir,j,i,mask,masku,maskv)
%=======================================================================================================
% input : 
% j,i : first guess river position
% dir : direction and sense of the flow 
%
% output : 
% j2,i2 : index position (eta, xi) at rho-point for runoff, in matlab convention 
% in MATLAB, rho, u and v indexing start at 1 ! 
%
%               MATLAB
%             |-------- v(i,j) -------|      
%             |                       |   
%             |                       |
%          u(i-1,j)     r(i,j)      u(i,j)
%             |                       |
%             |                       |   
%             |-------- v(i,j-1) -----| 
%
% j2for, i2for : index position (eta, xi) at rho-point for runoff, in CROCO convention
% in CROCO fortran, rho start at 0,  u and v indexing start at 1 !, 
%
% zero index is a ghost cell, with no staggerd u-point on right and v point below
%
%
%              CROCO fortran
%             |-------- v(i,j+1) -----|      
%             |                       |   
%             |                       |
%          u(i,j)       r(i,j)      u(i+1,j)
%             |                       |
%             |                       |   
%             |-------- v(i,j) -------| 
%
% j2for_out, i2for_out : index for runoff positions, at u and v cells, in CROCO fortran index convention.
%                       i- and j- are of the u or v cells that are flowing into the target wet cell 
%
% It is computed depending :
%     - the runoff direction (zonal=0, meridian=1)
%     - the sense (east-west/south-north =1 ; west-east/north-south =-1
%     - the landmask around ...
% 
%=======================================================================================================
if mask(j,i)==1
    disp('River positionned in sea')
    insea=1;
else
    disp('River positionned in land')
    insea=0;
end
if dir(1)==0
    if insea
        if dir(2)==1          % >> : west - east => TESTED
            while mask(j,i) == 1
                i=i-1;
                disp(['MASK:',num2str(mask(j,i))])
            end
            disp(['--'])
            disp(['MASK:',num2str(mask(j,i))])
            disp(['MASKU:',num2str(masku(j,i))])
        elseif dir(2)==-1     % << : east - west => TESTED
            while mask(j,i) == 1
                i=i+1;
                disp(['MASK:',num2str(mask(j,i))])
            end
            %in this case add +1 in i to get back into last wet cell
            j=j+1;
            disp(['--'])
            disp(['MASK:',num2str(mask(j,i))])
            disp(['MASKU:',num2str(masku(j,i))])
        end
    else %inland
        if dir(2) == 1         % >> :  west-est  => TESTED
            while mask(j,i) ~= 1
                i=i+1;
                disp(['MASK:',num2str(mask(j,i))])
            end
            disp(['--'])
            disp(['MASK:',num2str(mask(j,i))])
            disp(['MASKU:',num2str(masku(j,i))])
        elseif dir(2) == -1    % << : east-west => TESTED
            while mask(j,i) ~= 1
                i=i-1;
                disp(['MASK:',num2str(mask(j,i))])
            end
        disp(['--'])
        disp(['MASK:',num2str(mask(j,i))])
        disp(['MASKU:',num2str(masku(j,i))])
        end
    end
else %dir(k,1)=1
    if insea
        if dir(2) == 1 %  ^ : sud - nord => TESTED
            while mask(j,i) == 1
                j=j-1;
                disp(['MASK:',num2str(mask(j,i))])
            end
            %in this case add +1 in j to get back into last wet cell
            j=j+1;
            %   
            disp(['-- ^^ start insea'])
            disp(['MASK:',num2str(mask(j,i))])
            disp(['MASKV:',num2str(maskv(j,i))])
            
        elseif dir(2) == -1     % v : nord - sud  => TESTED
            while mask(j,i) == 1
                j=j+1;
                disp(['MASK:',num2str(mask(j,i))])
            end
            disp(['--'])
            disp(['MASK:',num2str(mask(j,i))])
            disp(['MASKV:',num2str(maskv(j,i))])

        end
    else %inland  
        if dir(2) == 1      % ^: sud-nord  => TESTED          
            while mask(j,i) ~= 1
                j=j+1;
                disp(['MASK:',num2str(mask(j,i))])
            end
            disp(['--^^ start inland'])
            disp(['MASK:',num2str(mask(j,i))])
            disp(['MASKV:',num2str(maskv(j,i))])

        elseif dir(2) == -1 % v : nord-sud => TESTED
            while mask(j,i) ~= 1
                j=j-1;
                disp(['MASK:',num2str(mask(j,i))])
            end
            disp(['--'])
            disp(['MASK:',num2str(mask(j,i))])
            disp(['MASKV:',num2str(maskv(j,i))])
        end
    end
end

% from matlab to roms index convention
j2=j; i2=i;
j2for=j-1; i2for=i-1;

% regarding the flow direction, sense and landmask surrounding
% -- toward west >>
if ( dir(1) == 0 & dir(2) == 1 ) ;
    j2for_out = j2for ;
    i2for_out = i2for ;
end
% -- toward est <<
if ( dir(1) == 0 & dir(2) == -1 );  
    j2for_out = j2for ;
    i2for_out = i2for + 1 ;
end
% -- toward north ^^
if ( dir(1) == 1 & dir(2) == 1 );  
    j2for_out = j2for ;
    i2for_out = i2for ;
end
% -- toward south vv
if ( dir(1) == 1 & dir(2) == -1 ); 
    j2for_out = j2for + 1 ;
    i2for_out = i2for ;
end

% j2mat_out is equal to j2for_out
% i2mat_out is equal to j2for_out % I think ...
% j2mat_out = j2for_out
% i2mat_out = i2for_out

return
