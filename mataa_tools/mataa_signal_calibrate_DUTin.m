function [s_cal,t,s_cal_unit] = mataa_signal_calibrate_DUTin (s,t,cal,verbose)

% function [s_cal,t,s_cal_unit] = mataa_signal_calibrate_DUTin (s,t,cal,verbose)
%
% DESCRIPTION:
% This function calibrates the signal s(t) at the input of a DUT using the given DAC(+BUFFER) calibration data, and it will also (try to) determine the unit of the calibrated data. In other words, this function "converts" the raw data sent to the sound inteface (DAC) to the physical signal at the DAC(+BUFFER) output as seen by the DUT. See illustration below.
%
% If s has more than one channel, different calibration information can be specified for the different channels.
%
% See also mataa_load_calibration and mataa_signal_calibrate_DUTin.
%
%   ILLUSTRATION (example with loudspeaker/DUT tested using a microphone):
%
%   MATAA / COMPUTER ----> DAC (+BUFFER) ---->    DUT     ---->   SENSOR  ---->  ADC (+PREAMP) ----> MATAA / COMPUTER
%    (dimensionless)      (dim.less -> V)      (V -> Pa)         (Pa -> V)      (V -> dim.less)      (dimensionless)
%
%       ===> unit of DUT output / sensor input signal (h_cal) is Pa
% 
% INPUT:
% s: signal samples (unit: dimensionless data as obtained by ADC / soundcard)
% t: time coordinates of samples in h (vector, in seconds) or sampling rate of h (scalar, in samples per second)
% cal: name of calibration file or calibration data (struct object as obtained from mataa_load_calibration). cal struct must contain DAC field. For calibration of more than one data channels, cal can be specified as a cell array, whereby each cell element is used for the corresponding data channel.
% verbose (optional): flag to control verbosity (bool, default: verbose = false)
% 
% OUTPUT:
% s_cal: calibrated signal
% t: time coordinates of samples in h
% s_cal_unit: unit of h_cal (string), i.e. the unit of the calibrated DUT signal
% 
% EXAMPLE
% Feed a 1 kHz sine-wave signal to the DUT and measure the raw response signal without calibration; then calibrate raw data according to GENERIC_CHAIN_DIRECT.txt cal file:
% > fs = 44100;
% > [s,t] = mataa_signal_generator ('sine',fs,0.2,1000);
% > [out,in,t,out_unit,in_unit] = mataa_measure_signal_response(s,fs,0.1,1,1);
% > [X,t_X,unit_X] = mataa_signal_calibrate_DUTin (in,t,'GENERIC_CHAIN_DIRECT.txt'); % calibrate signal at DUT input / DAC(+BUFFER) output
% > [Y,t_Y,unit_Y] = mataa_signal_calibrate_DUTout (out,t,'GENERIC_CHAIN_DIRECT.txt'); % calibrate signal at DUT out / ADC input
% > subplot (2,1,1); plot (t_X,X); ylabel (sprintf('Signal at DUT input (%s)',unit_X));
% > subplot (2,1,2); plot (t_Y,Y); ylabel (sprintf('Signal at DUT output (%s)',unit_Y));
% > xlabel ('Time (s)')
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
% Copyright (C) 2006, 2007, 2008, 2015 Matthias S. Brennwald.
% Contact: info@audioroot.net
% Further information: http://www.audioroot.net/MATAA

if ~exist('verbose','var')
	verbose = false;
end

if isscalar(t)
    t = [0:1/t:(length(s)-1)/t];
end

if ischar(cal) % name of calibration file instead of cal struct
	cal = mataa_load_calibration (cal);
end

if size(s,2) > 1 % s has more than one data channel
	s_cal = [];
	s_cal_unit = {};
	if ~iscell(cal) % convert to cell array for the loop below
		u{1} = cal;
		cal = u;
		clear u;
	end
	nCal = length(cal);
	for k = 1:size(s,2)
		if verbose
			disp (sprintf("Calibrating channel %i...",k))
		end
				
		% check if cal data available for k-th channel:
		if nCal < k
			warning (sprintf("mataa_calibrate_DUTin: no calibration data available for channel %i. Will use calibration data given for channel %i!",k,nCal));
			kk = nCal;
		else
			kk = k;
		end
		[x,t,u] = mataa_signal_calibrate_DUTin (h(:,k),t,cal{kk});
		s_cal = [ s_cal x ];
		s_cal_unit{k} = u;
	end
	
else

	if ~isfield(cal,'DAC')
		error (sprintf("mataa_calibrate_DUTin: cal data for '%s' has no DAC data!",cal.name));
	end

	% determine DUT input voltage
	if verbose
		disp (sprintf("Determining DUT input signal from DAC '%s'...",cal.DAC.name))
	    	disp (sprintf("     sensitivity = %g %s.",cal.DAC.sensitivity,cal.DAC.sensitivity_unit));
	end
    	s_cal = s * cal.DAC.sensitivity;
	s_cal_unit = cal.DAC.sensitivity_unit;

	if isfield (cal.DAC,'transfer')
		warning (sprintf("mataa_calibrate_DUTin: compensation for frequency-dependent transfer function of DAC is not implemented. Ignoring transfer function of DAC '%s'!",cal.DAC.name));
	end
	
end
