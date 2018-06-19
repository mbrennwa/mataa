function c = RTX6001_AUTOSCALINGFUNCTION_DAC_SE(channel);

% function c = RTX6001_AUTOSCALINGFUNCTION_DAC_SE(channel);
%
% DESCRIPTION:
% Determine current sensitivity settings for DAC (SINGLE-ENDED BNC output) and return as cal struct.
%
% INPUT:
% channel: channel string ('left' or 'right')
%
% OUTPUT:
% c: cal struct corresponding to the left or right channel
%
% DISCLAIMER:
% This file is part of MATAA.
% 
% MATAA is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
% 
% MATAA is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
% 
% You should have received a copy of the GNU General Public License
% along with MATAA; if not, write to the Free Software
% Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
% 
% Copyright (C) 2006, 2007, 2008 Matthias S. Brennwald.
% Contact: info@audioroot.net
% Further information: http://www.audioroot.net/MATAA

[s,x] = system( [ mataa_path('calibration') 'RTX6001_USB_STATUS' ] );
if s
	error ('RTX6001_AUTOSCALINGFUNCTION_DAC_SE: error running the RTX-USB utility.')
end

x = strsplit(x,'\n'){1}; % first line
x = strsplit (x,'\t'); % separate fields

% FORMAT:
% x = {
%  [1,1] = Output_left=0 dBV
%  [1,2] = Output_right=+20 dBV
%  [1,3] = Input_left=-20 dBV(AC)
%  [1,4] = Input_right=-20 dBV(DC)
%}

ch = toupper(channel);
switch ch
	case 'LEFT'
		k = 1;
	case 'RIGHT'
		k = 2;
	otherwise
		error (sprintf('RTX6001_AUTOSCALINGFUNCTION_DAC_SE: cannot parse channel identifier (%s).',channel))
end


c.DAC.sensitivity_unit = 'V';
u = strsplit (x{k},'='){2}(1:end);
switch u
	case '-20 dBV'
		c.DAC.name = 'RTX6001 100-mV SINGLE-ENDED OUTPUT';
		c.DAC.sensitivity = 0.1*sqrt(2)/2;
	case '0 dBV'
		c.DAC.name = 'RTX6001 1-V SINGLE-ENDED OUTPUT';
		c.DAC.sensitivity = sqrt(2)/2;
	case '+20 dBV'
		c.DAC.name = 'RTX6001 10-V SINGLE-ENDED OUTPUT';
		c.DAC.sensitivity = 10*sqrt(2)/2;
	otherwise
		error (sprintf('RTX6001_AUTOSCALINGFUNCTION_DAC_SE: cannot parse DAC sensitivity string (%s).',u))
end
c.DAC.name = [ c.DAC.name ' (' ch ')' ];


