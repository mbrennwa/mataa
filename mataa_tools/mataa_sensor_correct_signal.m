function [h_corr,t] = mataa_sensor_correct_signal (calfile,h,t)

% function [h,t] = mataa_sensor_correct_signal (calfile,h,t)
%
% DESCRIPTION:
% This function corrects a signal h(t) from the transfer function of the specified sensor (e.g., a microphone).
% The phase response of the sensor ist calculated by assuming the sensor to be minimum phase.
% The sensor transfer function (relative gain) is taken from a file in the MATAA 'sensor_data' path (see example files in this path for data format).
% Gain at frequencies outside the range of the specified sensor response is set to zero (= -inf dB)
% 
% INPUT:
% calfile: name of calibration file (e.g., 'Behringer_ECM8000_transfer.txt')
% h: signal samples
% t: time coordinates of samples in h (vector, in seconds) or sampling rate of h (scalar, in Hz)
% 
% OUTPUT:
% h_corr: corrected signal
% t: time coordinates of samples in h
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

if isscalar(t)
    t = [0:1/t:(length(h)-1)/t];
end

if size(h,2) > 1 % h has more than one data channel
	h_corr = [];
	for k = 1:size(h,2)
		[u,t] = mataa_sensor_correct_signal (calfile,h(:,k),t);
		h_corr = [ h_corr u ];
	end
	
else
	
	oldPath = pwd;
	cd(mataa_path('sensor'));
	
%	calfile = [ calfile '_transfer.txt' ];
		
	if exist(calfile,"file")
		
		if exist('OCTAVE_VERSION','builtin')
			more('off'),
		end
		
%		disp(sprintf('Correcting impulse response for sensor characteristics using data from the file %s (this may take a while)...',calfile));

		h = h(:);
		
	   signal_cropped = 0;
		if mod(length(h),2)
		   h = h(1:end-1);
		   t = t(1:end-1);
		   signal_cropped = 1;
	    end
	    
		x=load(calfile);
		cd(oldPath);
	
		f0 = x(:,1);
		sens_spl_0 = x(:,2);
		if size(x,2) > 2
			warning ('mataa_sensor_correct_signal: calibration data has more than two columns. Data after second column is ignored!');
		end
		clear x;
		
		[f0,k] = sort (f0); sens_spl_0 = sens_spl_0(k);
		
		fMax=max(f0); fMin=min(f0); % we'll need these further below
		
		T = max(t)-min(t); % length of h
		f = [1/T:1/T:length(t)/2*1/T]'; % frequency values corresponding to Fourier transform of h
		clear T
			
		% Interpolate sensor frequency response to frequency values f:
	%	sens_spl=repmat(NaN,length(f),1);
	%	for i=1:length(f);
	%		sens_spl(i) = mataa_interp(f0,sens_spl_0,f(i));	
	%	end
		sens_spl = interp1 (f0,sens_spl_0,f);
		
		% make sure sens_spl does not contain any NA or NaN values (data out of frequency range of calibration file will be dealt with later):
		if any(f<f0(1))
			sens_spl(f<f0(1)) = sens_spl_0(1);
		end
		if any(f>f0(end))
			sens_spl(f>f0(end)) = sens_spl_0(end);
		end
				
		% calculate minimum phase of sensor:
		i = sqrt(-1); % make sure we don't have something else assigned to 'i'
		sens_phase = -mataa_hilbert(sens_spl/20); % phase in radians
				
		% complex fourier spectrum of sensor transfer function:
		sens_p = 10.^(sens_spl/20).*exp(i*sens_phase); 
		
		% make up second half of fourier spectrum:
		% first entry: DC component ( set this to NaN )
		% first half = sens_p
		% middle point belongs to both halves
		% second half = conj(fliplr(sens_p)), because the impulse response of the sensor is real
		
		sens_p = sens_p(:)';
		P = [ NaN sens_p conj(fliplr(sens_p(1:end-1))) ];
	
		% remove components with f > fMax of f < fMin from h
		H = mataa_realFT(h,t); % get the 'real' half of the fourier specturm of h
			
		H(find(f>fMax)) = 0; % remove components with f>fMax
		H(find(f<fMin)) = 0; % remove components with f<fMin
		
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
	
	else
		disp(sprintf('WARNING: Could not correct for sensor characteristics, because the file %s was not found.',calfile))
		h_corr = h;
		cd(oldPath);
	end
end
