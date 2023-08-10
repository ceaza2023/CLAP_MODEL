function write_mercator_frcst(FRCST_dir,FRCST_prefix,raw_mercator_name,...
                              mercator_type,vars,time,Yorig)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Extract a subset from Marcator using python motu client (cls)
% Write it in a local file (keeping the classic SODA netcdf format)
% 
%  Further Information:  
%  http://www.croco-ocean.org
%  
%  This file is part of CROCOTOOLS
%
%  CROCOTOOLS is free software; you can redistribute it and/or modify
%  it under the terms of the GNU General Public License as published
%  by the Free Software Foundation; either version 2 of the License,
%  or (at your option) any later version.
%
%  CROCOTOOLS is distributed in the hope that it will be useful, but
%  WITHOUT ANY WARRANTY; without even the implied warranty of
%  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%  GNU General Public License for more details.
%
%  You should have received a copy of the GNU General Public License
%  along with this program; if not, write to the Free Software
%  Foundation, Inc., 59 Temple Place, Suite 330, Boston,
%  MA  02111-1307  USA
%
%  Copyright (c) 2006 by Pierrick Penven 
%  e-mail:Pierrick.Penven@ird.fr  
%
%  Updated    9-Sep-2006 by Pierrick Penven
%  Updated    19-May-2011 by Andres Sepulveda & Gildas Cambon
%  Updated    12-Feb-2016 by P. Marchesiello
%  Updated    06-May-2023 by Efrain Rodriguez-Rubio & P. Marchesiello
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
disp(['    writing MERCATOR file'])

fname_z=[raw_mercator_name(1:end-3),'_z.nc'];
fname_u=[raw_mercator_name(1:end-3),'_u.nc'];
fname_t=[raw_mercator_name(1:end-3),'_t.nc'];
fname_s=[raw_mercator_name(1:end-3),'_s.nc'];

%
% Get grid and time frame
%
nc = netcdf(fname_u,'r');
if mercator_type==1,
  lon = nc{'longitude'}(:);
  lat = nc{'latitude'}(:);
  depth = nc{'depth'}(:);
  time = nc{'time'}(:);
  time = time / 24 + datenum(1950,1,1) - datenum(Yorig,1,1);
else
  lon = nc{'lon'}(:);
  lat = nc{'lat'}(:);
  depth = nc{'depth'}(:);
  time = nc{'time'}(:);
  time = time / 86400 + datenum(2014,1,9) - datenum(Yorig,1,1);
end
close(nc)
%
% Get SSH
%
%missval = -32767;
disp('    ...SSH')
nc = netcdf(fname_z,'r');
vname=sprintf('%s',vars{1});
ncc=nc{vname};
ssh=ncc(:);
missval=ncc.FillValue_(:);
scale_factor=1; %ncc.scale_factor(:);
add_offset=0.;  %ncc.add_offset(:);
ssh(ssh>=missval)=NaN;
ssh = ssh.*scale_factor + add_offset;
close(nc)
%
%
% Get U
%
disp('    ...U')
nc = netcdf(fname_u,'r');
vname=sprintf('%s',vars{2});
ncc=nc{vname};
u=ncc(:);
missval=ncc.FillValue_(:);
scale_factor=1; %ncc.scale_factor(:);
add_offset=0.;  %ncc.add_offset(:);
u(u>=missval)=NaN;
u = u.*scale_factor + add_offset;
close(nc)
%
% Get V
%
disp('    ...V')
nc = netcdf(fname_u,'r');
vname=sprintf('%s',vars{3});
ncc=nc{vname};
v=ncc(:);
missval=ncc.FillValue_(:);
scale_factor=1; %ncc.scale_factor(:);
add_offset=0.;  %ncc.add_offset(:);
v(v>=missval)=NaN;
v = v.*scale_factor + add_offset;
close(nc)
%
% Get TEMP
%
disp('    ...TEMP')
nc = netcdf(fname_t,'r');
vname=sprintf('%s',vars{4});
ncc=nc{vname};
temp=ncc(:);
missval=ncc.FillValue_(:);
scale_factor=1; %ncc.scale_factor(:);
add_offset=0.;  %ncc.add_offset(:);
ktoc=272.15;
temp(temp>=missval)=NaN;
temp = temp.*scale_factor + add_offset; % - ktoc;
close(nc)
%
% Get SALT
%
disp('    ...SALT')
nc = netcdf(fname_s,'r');
vname=sprintf('%s',vars{5});
ncc=nc{vname};
salt=ncc(:);
missval=ncc.FillValue_(:);
scale_factor=1; %ncc.scale_factor(:);
add_offset=0.;  %ncc.add_offset(:);
salt(salt>=missval)=NaN;
salt = salt.*scale_factor + add_offset;
close(nc)
%
% Create the Mercator file
%
rundate_str=date;
rundate=datenum(rundate_str)-datenum(Yorig,1,1);

create_OGCM([FRCST_dir,FRCST_prefix,num2str(rundate),'.cdf'],...
             lon,lat,lon,lat,lon,lat,depth,time,...
             squeeze(temp),squeeze(salt),squeeze(u),...
             squeeze(v),squeeze(ssh),Yorig)
%
return

end

