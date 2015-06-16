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

if isscalar(t)
    t = [0:1/t:(length(h)-1)/t];
end

if ischar(cal) % name of calibration file
	cal = mataa_load_calibration (cal);
end

if size(h,2) > 1 % h has more than one data channel
	h_corr = [];
	for k = 1:size(h,2)
		[u,t] = mataa_sensor_correct_signal (cal,h(:,k),t);
		h_corr = [ h_corr u ];
	end
	
else

	h = h(:);



	disp (sprintf("Calibrating for %s '%s':",cal.type,cal.name))
	if ~isfield (cal,'sensitivity')
		disp ('     sensitivity unknown!')
	else	
		disp (sprintf('     sensitivity: %g %s.',cal.sensitivity.val,sensitivity.unit))
		if strcmp (cal.type,'DAC)
			responseSignal(:,k) = responseSignal(:,k) * cal.sensitivity; % DAC sits before DUT
			
		else
			responseSignal(:,k) = responseSignal(:,k) / cal.sensitivity; % ADC and SENSOR sit after DUT
		end
	end
			




				disp (sprintf('Compensating for sensor \"%s\":',hw_info{k}.sensor.name))
				
				% process sensitivity (including data units)
				if ~isfield (hw_info{k}.sensor,'sensitivity')
					disp ('     sensitivity unknown!')
				else
					disp (sprintf('     sensitivity: %g %s.',hw_info{k}.sensor.sensitivity.val,hw_info{k}.sensor.sensitivity.unit))
					responseSignal(:,k) = responseSignal(:,k) / hw_info{k}.sensor.sensitivity.val;
					uu = [];				
					if strcmp(hw_info{k}.sensor.sensitivity.unit(1),'V')
						kk = findstr (hw_info{k}.sensor.sensitivity.unit,'/');
						if any(kk)
							if kk(1) < length(hw_info{k}.sensor.sensitivity.unit)
								uu = hw_info{k}.sensor.sensitivity.unit(kk(1)+1:end);
							end
						end
					end
					if isempty (uu)
						warning (sprintf('mataa_measure_signal_response: dont know how to parse units of sensor signal (%s).',hw_info{k}.sensor.sensitivity.unit))
						signal_unit = '?';
					else
						signal_unit = uu;
					end
				end
							
				% process calibration file / transfer function
				if ~isfield (hw_info{k}.sensor,'calfile')
					disp ('     calibration file / transfer function unknown!')
				else
					disp (sprintf('     calibration file: %s.',hw_info{k}.sensor.calfile))
					responseSignal(:,k) = mataa_sensor_correct_signal (hw_info{k}.sensor.calfile,responseSignal(:,k),t);	
				end
			
			end
		end
	
	end
	
	










	
	if isfield (cal,'transfer')	% compensate for transfer function
	    
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
		gain = interp1 (cal.transfer.f,cal.transfer.val,f);
		
		% make sure gain does not contain any NA or NaN values (data out of frequency range of calibration file will be dealt with later):
		if any( f < cal.transfer.f(1) )
		    gain( f < cal.transfer.f(1) ) = cal.transfer.val(1);
		end
		if any( f > cal.transfer.f(end) )
		    gain( f > cal.transfer.f(end) ) = cal.transfer.val(end);
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
		
		% remove components with f > cal.transfer.f(end) of f < cal.transfer.f(1) from h
		H = mataa_realFT(h,t); % get the 'real' half of the fourier specturm of h
		    
		H(find(f>cal.transfer.f(end))) = 0; % remove components with f > cal.transfer.f(end)
		H(find(f<cal.transfer.f(1)))   = 0; % remove components with f < cal.transfer.f(1)
		
		H = H(:)';
		H = [ 0 H conj(fliplr(H(1:end-1))) ]; % make up full fourier spectrum of h
		
		% normalize H by P (deconvolve h from impulse response of sensor):
		H_corr = H ./ P;
		
		H_corr(1) = 0; % 'repair' the NaN DC-value, remember: P(1)=NaN )
		h_corr = real(ifft(H_corr));
		
		h_corr = h_corr(:);
		t = t(:);
		
		if signal_cropped
		    h_corr = [ h_corr ; h_corr(end) ];
		    t = [ t ; t(end) + t(end)-t(end-1) ];
		end
	
		disp('...done.');
	end
end
