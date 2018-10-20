function cal = mataa_cal_autoscale (c);

% function cal = mataa_cal_autoscale (c);
%
% DESCRIPTION:
% Execute the "autoscaling" function(s) for the ADC and DAC device(s) described by the calibration struct c, and return the ADC and DAC sensitivites in cal struct in the same format as with fixed/non-autoscaling calibration structs.
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
% Copyright (C) 2018 Matthias S. Brennwald.
% Contact: info@audioroot.net
% Further information: http://www.audioroot.net/MATAA

if ischar(c) % name of calibration file instead of cal struct
	c = mataa_load_calibration (c);
end

if length(c) > 1 % array of multiple cal structs
	for i = 1:length(c)
		cal{i} = mataa_cal_autoscale (c{i});
	end
else

	cal_adc = [];
	cal_dac = [];
	
	if isfield (c,'ADC')
		if isfield (c.ADC,'sensitivity_autoscalefunction')
			eval ( sprintf( "u = %s;",c.ADC.sensitivity_autoscalefunction ) );
			cal_adc = u;
		end
	end

	if isfield (c,'DAC')
		if isfield (c.ADC,'sensitivity_autoscalefunction')
			eval ( sprintf( "u = %s;",c.DAC.sensitivity_autoscalefunction ) );
			cal_dac = u;
		end
	end

	cal = c; % copy all fields (including SENSORs etc.)

	if not(isempty(cal_adc))
		% overwrite with autoscaling result:
		cal.ADC = cal_adc.ADC;
	end

	if not(isempty(cal_dac))
		% overwrite with autoscaling result:
		cal.DAC = cal_dac.DAC;
	end

end
