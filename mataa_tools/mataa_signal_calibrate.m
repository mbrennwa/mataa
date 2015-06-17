function [h_corr,t,unit] = mataa_signal_calibrate (h,t,cal)

% function [h_corr,t,unit] = mataa_signal_calibrate (h,t,cal)
%
% DESCRIPTION:
% This function calibrates a signal h(t) using the given calibration data (e.g., for a specific audio interface, microphone, sensor, etc), and it will also (try to) determine the unit of the calibrated data. The phase information of the transfer function ist calculated by assuming the device to be minimum phase.
% If h has more than one channel, all channels will be calibrated using the same calibration data.
% See also mataa_load_calibration.
% 
% INPUT:
% cal: name of calibration file (e.g., 'Behringer_ECM8000_transfer.txt') or calibration data (struct object as obtained from mataa_load_calibration).
% h: signal samples
% t: time coordinates of samples in h (vector, in seconds) or sampling rate of h (scalar, in Hz)
% 
% OUTPUT:
% h_corr: corrected signal
% t: time coordinates of samples in h
% unit: unit of h_corr (string)
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
function [h,t,u] = __calib (h,t,u,subcal,type)
h = h(:);	
disp (sprintf("Calibrating for %s '%s':",type,subcal.name))
    if ~isfield (cal,'sensitivity')
    	switch toupper(type) % guess sensitivity value and unit
    		case 'DAC' % assume sensitivity = 1 V
    			sv = 1;
    			su = 'V';
    		case {'SENSOR'} % assume 1 mV/Pa
    			sv = 1E-3;
    			su = 'V/Pa';
    		case 'ADC' % assume sensitivity = 1 per V
    			sv = 1;
    			su = '1/V';
    		otherwise
    			error (sprintf("mataa_signal_calibrate: device type '%s' unknown.",type))
    	end
		disp (sprintf("     sensitivity unknown! Assuming sensitivity = %g %s",sv,su))
    else
    	sv = subcal.sensitivity.val;
    	su = subcal.sensitivity.unit;
    	disp (sprintf("     sensitivity = %g %s.",sv,su))    	
    end
   	h = h / sv;
	
	%%% take care of unit conversion here...

    % compensate for transfer function
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
    	
    	% make sure gain does not contain any NA or NaN values (data out of frequency range of calibration file will be dealt with later):
    	if any( f < subcal.transfer.f(1) )
    	    gain( f < subcal.transfer.f(1) ) = subcal.transfer.gain(1);
    	end
    	if any( f > subcal.transfer.f(end) )
    	    gain( f > subcal.transfer.f(end) ) = subcal.transfer.gain(end);
    	end
    	
    	% calculate minimum phase of device:
    	i = sqrt(-1); % make sure we don't have something else assigned to 'i'
    	phase = -mataa_hilbert(gain/20); % phase in radians
    	    	
    	% complex fourier spectrum of sensor transfer function:
    	pp = 10.^(gain/20).*exp(i*phase); 
    	
    	% make up second half of fourier spectrum:
    	% first entry: DC component ( set this to NaN )
    	% first half = pp
    	% middle point belongs to both halves
    	% second half = conj(fliplr(pp)), because the impulse response of the sensor is real
    	
    	pp = pp(:)';
    	P = [ NaN pp conj(fliplr(pp(1:end-1))) ];
    	
    	% remove components with f > subcal.transfer.f(end) of f < subcal.transfer.f(1) from h
    	H = mataa_realFT(h,t); % get the 'real' half of the fourier specturm of h
    	    
    	H(find(f>subcal.transfer.f(end))) = 0; % remove components with f > subcal.transfer.f(end)
    	H(find(f<subcal.transfer.f(1)))   = 0; % remove components with f < subcal.transfer.f(1)
    	
    	H = H(:)';
    	H = [ 0 H conj(fliplr(H(1:end-1))) ]; % make up full fourier spectrum of h
    	
    	% normalize H by P (deconvolve h from impulse response of sensor):
    	H= H ./ P;
    	
    	H(1) = 0; % 'repair' the NaN DC-value, remember: P(1)=NaN )
    	h = real(ifft(H));
    	
    	h = h(:);
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

if size(h,2) > 1 % h has more than one data channel
	h_corr = [];
	for k = 1:size(h,2)
		disp (sprintf("Calibrating channel %i...",k))
		[x,t] = mataa_signal_calibrate (cal,h(:,k),t);
		h_corr = [ h_corr x ];
	end
	
else

	u = "SOME UNIT THAT NEEDS MORE ATTENTION";

	if ~isfield (cal,'DAC')
		disp ("No DAC calibation data available!")
	else
		[h,t,u] = __calib (h,t,u,cal.DAC,'DAC');
	end
	
	if ~isfield (cal,'SENSOR')
		disp ("No SENSOR calibation data available!")
	else
		[h,t,u] = __calib (h,t,u,cal.SENSOR,'SENSOR');
	end
	
	if ~isfield (cal,'ADC')
		disp ("No ADC calibation data available!")
	else
		[h,t,u] = __calib (h,t,u,cal.ADC,'ADC');
	end

end

h_corr = h;
unit = u;

warning ("mataa_measure_signal_response: implementation of data calibration is still experimental!");

end % main function