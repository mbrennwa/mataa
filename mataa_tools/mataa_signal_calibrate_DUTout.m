function [s_cal,t,s_cal_unit] = mataa_signal_calibrate_DUTout (s,t,cal)

% function [s_cal,t,s_cal_unit] = mataa_signal_calibrate_DUTout (s,t,cal)
%
% DESCRIPTION:
% This function calibrates the signal s(t) at the output of a DUT using the given calibration data (e.g., for a specific audio interface, microphone, sensor, etc), and it will also (try to) determine the unit of the calibrated data. In other words, this function "converts" the raw data recorded by the sound inteface (ADC) to the physical signal seen by the sensor (e.g., by a measurement microphone). See illustration below.
%
% If the transfer function of the analytical chain (sensor, microphone, etc.) given in the cal data is specified using magnitude only (i.e, without phase information), the phase of the transfer function is calculated by assuming a minimum phase system (for example, if the transfer function of a measurement microphone is given by magnitude, it's phase is determined by assuming minimum phase). The DUT response signal is then compensated for the full transfer function taking into account both magnitude and phase.
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
% cal: name of calibration file (e.g., 'Behringer_ECM8000_transfer.txt') or calibration data (struct object as obtained from mataa_load_calibration). cal data must contain ADC and SENSOR fields. For calibration of more than one data channels, cal can be specified as a cell array, whereby each cell element is used for the corresponding data channel.
% NOTE: for use with multiple calibration channels, the size of the cell arrays SENSOR_cal and ADC_cal must be the same
% 
% OUTPUT:
% s_cal: calibrated signal
% t: time coordinates of samples in h
% s_cal_unit: unit of h_cal (string), i.e. the unit of the calibrated DUT signal
% 
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

% helper function for calibration of various units
function [h,t] = __calib (h,t,subcal,type)
h = h(:);	
disp (sprintf("Calibrating for %s '%s':",type,subcal.name))
    if ~isfield (subcal,'sensitivity') % don't know the sensitivity...
    	switch toupper(type) % guess sensitivity value and unit
    		case {'SENSOR'} % assume "loopback" / wire with sensitivity = 1 V / V (sensor output is the same as input)
    			sv = 1;
    			su = 'V/V';
    		case 'ADC' % assume sensitivity = 1 per V
    			sv = 1;
    			su = '1/V';
    		otherwise
    			error (sprintf("mataa_signal_calibrate_DUTout: device type '%s' unknown.",type))
    	end
		disp (sprintf("     sensitivity unknown! Assuming sensitivity = %g %s",sv,su))
    else
    	sv = subcal.sensitivity;
    	su = subcal.sensitivity_unit;
    	disp (sprintf("     sensitivity = %g %s.",sv,su)) 	
    end
    
    % compensate for sensitivity:
    h = h / sv;

    % check if units are as expected:	
    if strcmp(toupper(type),'ADC') % ADC sensitivity should be 1/V
        if ~strcmp (subcal.sensitivity_unit,'1/V')
   	    error (sprintf("mataa_signal_calibrate_DUTout: ADC sensitivity must be given in 1/V, not '%s'.",subcal.sensitivity_unit))
    	end
    end

%   		case 'SENSOR' % currently, only V/Pa and V/V are supported as unit for SENSOR sensitivity 
%   			if ~any(strcmp (subcal.sensitivity_unit,{'V/Pa' 'V/V'}))
%   				error (sprintf("mataa_signal_calibrate_DUTout: SENSOR sensitivity must be given in V/Pa or V/V, not '%s'.",subcal.sensitivity_unit))
%    		end
%
%   	otherwise
%    		error (sprintf("mataa_signal_calibrate_DUTout: device type '%s' unknown.",type))
%    end
    	
    % compensate for transfer function (frequency response of SENSOR or ADC/aliasing filter):
    if ~isfield (subcal,'transfer')
    	disp ("     transfer function unknown, assuming constant unity gain.")
    else
        
    	disp (sprintf("     compensating for transfer function (%i data points).",length(subcal.transfer.f)))
        	
        % Make sure length of h is even:
        signal_cropped = 0;
    	if mod(length(h),2)
    	   h = h(1:end-1);
    	   t = t(1:end-1);
    	   signal_cropped = 1;
    	end

    	T = max(t)-min(t); % length of h
    	f = [1/T:1/T:length(t)/2*1/T]'; % frequency values corresponding to Fourier transform of h
    	clear T
    	    
    	% Interpolate device frequency response to frequency values f:
        gain = interp1 (subcal.transfer.f,subcal.transfer.gain,f);
        if isfield (subcal.transfer,'phase') % phase given explicitly
	        phase = interp1 (subcal.transfer.f,subcal.transfer.phase,f);
    	end
    	
    	% make sure gain (and phase) does not contain any NA or NaN values (data out of frequency range of calibration file will be dealt with later):
    	if any( f < subcal.transfer.f(1) )
    	    gain( f < subcal.transfer.f(1) ) = subcal.transfer.gain(1);
    	    if exist ('phase','var')
    	    	phase( f < subcal.transfer.f(1) ) = subcal.transfer.phase(1);
    	    end
    	end
    	if any( f > subcal.transfer.f(end) )
    	    gain( f > subcal.transfer.f(end) ) = subcal.transfer.gain(end);
    	    if exist ('phase','var')
    	    	phase( f > subcal.transfer.f(end) ) = subcal.transfer.phase(end);
    	    end
    	end
		
    	% calculate minimum phase of device if necessary:    	
    	if ~exist ('phase','var')
	    	i = sqrt(-1); % make sure we don't have something else assigned to 'i'
    		%%% phase = -mataa_hilbert(gain/20); % phase in radians THIS SEEMS WRONG DUE TO MIXUP BETWEEN LOG-10 (from dB scale) vs. LOG-NAT (as needed for Hilbert transform)
    		phase = mataa_minimum_phase (gain)/180*pi; % phase in radians
    	end
    	
    	% complex fourier spectrum of sensor transfer function:
    	pp = 10.^(gain/20) .* exp(i*phase); 
    	    	
    	% make up second half of fourier spectrum:
    	% first entry: DC component ( set this to NaN )
    	% first half = pp
    	% middle point belongs to both halves
    	% second half = conj(fliplr(pp)), because the impulse response of the sensor is real
    	
    	pp = pp(:)';
    	P = [ NaN pp conj(fliplr(pp(1:end-1))) ];
    	
    	H = mataa_realFT(h,t); % get the 'real' half of the fourier specturm of h

	%%% DON'T DO THIS, IT SCREWS UP THE DATA / SPECTRUM!
    	%%% % remove data outside of sensor transfer function range:
    	%%% H(find(f>subcal.transfer.f(end))) = 0; % remove components with f > subcal.transfer.f(end)
    	%%% H(find(f<subcal.transfer.f(1)))   = 0; % remove components with f < subcal.transfer.f(1)
    	
    	% deconvolve H from P
    	H = H(:)';
    	H = [ 0 H conj(fliplr(H(1:end-1))) ]; % make up full fourier spectrum of h
    	
    	% normalize H by P (deconvolve h from impulse response of sensor):
		H0 = H;

    	H = H ./ P;
    	
    	H(1) = 0; % 'repair' the NaN DC-value, remember: P(1)=NaN )
		
	h0 = h;
    	h = ifft(H);
    	h = abs(h) .* sign(real(h)); % turn it back to the real-axis (complex part is much smaller than real part, so this works fine)
    	
    	h = flipud (h(:));
    	t = t(:);
		
    	if signal_cropped
    	    h = [ h ; h(end) ];
    	    t = [ t ; t(end) + t(end)-t(end-1) ];
    	end
    
    	disp('...done.');
    end % isfield (subcal,'transfer')

end % __calib function






%%%%%%%%%%%%%%%%%%%%%%%%
% Main function
%%%%%%%%%%%%%%%%%%%%%%%%


if isscalar(t)
    t = [0:1/t:(length(h)-1)/t];
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
	for k = 1:size(h,2)
		disp (sprintf("Calibrating channel %i...",k))
				
		% check if cal data available for k-th channel:
		if nCal < k
			warning (sprintf("mataa_calibrate_DUTout: no calibration data available for channel %i. Will use calibration data given for channel %i!",k,nCal));
			kk = nCal;
		else
			kk = k;
		end
		[x,t,u] = mataa_signal_calibrate_DUTout (h(:,k),t,cal{kk},out_amplitude(k));
		s_cal = [ h_cal x ];
		s_cal_unit{k} = u;
	end
	
else

	if ~isfield (cal,'SENSOR')
		disp ("No SENSOR calibation data available!")
		unit_SENSOR_sensitivity = '???';
	else
		[s_cal,t] = __calib (s,t,cal.SENSOR,'SENSOR');
		unit_SENSOR_sensitivity = cal.SENSOR.sensitivity_unit;
	end
	
	if ~isfield (cal,'ADC')
		disp ("No ADC calibation data available!")
		unit_ADC_sensitivity = '1/V';
	else
		[s_cal,t] = __calib (s,t,cal.ADC,'ADC');
		unit_ADC_sensitivity = cal.ADC.sensitivity_unit;
	end

	% determine unit of DUT output signal:
	% DUT-unit = 1 / SENSOR-unit / ADC-unit
	u_SENS = strsplit (unit_SENSOR_sensitivity,"/");
	u_ADC = strsplit (unit_ADC_sensitivity,"/");
	if ~strcmp(u_SENS{1},u_ADC{2})
		warning ('mataa_signal_calibrate_DUTout: units of SENSOR and ADC do not match! Cannot determine unit of DUT output...');
		s_cal_unit = '???';
	else
		s_cal_unit = u_SENS{2};
	end

	
end

end % main function
