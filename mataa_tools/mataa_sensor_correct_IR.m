function [h_corr,t] = mataa_sensor_correct_IR (sens_name,h,t)

% function [h,t] = mataa_sensor_correct_IR (sens_name,h,t)
%
% DESCRIPTION:
% This function corrects h(t) from the transfer function of the specified sensor (e.g., a microphone).
% The phase response of the sensor ist calculated by assuming the sensor to be minimum phase.
% The sensor transfer function (relative gain) is taken from a file in the MATAA 'sensor_data' path (see example files in this path for data format).
% Gain at frequencies outside the range of the specified sensor response is set to zero (= -inf dB)
% 
% INPUT:
% sens_name: name of sensor
% h: impulse response samples
% t: time coordinates of samples in h (vector, in seconds) or sampling rate of h (scalar, in Hz)
% 
% OUTPUT:
% h_corr: corrected impulse response
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

oldPath = pwd;
cd(mataa_path('sensor'));

sens_name = [ sens_name '_transfer.txt' ];

if exist(sens_name)==2
	
	
	if exist('OCTAVE_VERSION','builtin')
		more('off'),
	end
	
	disp(sprintf('Correcting impulse response for sensor characteristics using data from the file %s (this may take a while)...',sens_name));
	
	h = h(:);
	if mod(length(h),2)
	   h = h(1:end-1);
	   t = t(1:end-1);
    end
    
	x=load(sens_name);
	f0 = x(:,1);
	sens_spl_0 = x(:,2);
	if size(x,2) > 2
		warning ('mataa_sensor_correct_IR: calibration data has more than two columns. Data after second column is ignored!');
	end
	clear x
	
	fMax=max(f0); fMin=min(f0); % we'll need these further below
	
	T = max(t)-min(t);
	f = [1/T:1/T:length(t)/2*1/T];
	clear T
		
	sens_spl=repmat(NaN,length(f),1);
	for i=1:length(f);
		sens_spl(i) = mataa_interp(f0,sens_spl_0,f(i));	
	end
	
	
	% calculate minimum phase of sensor:
	i = sqrt(-1); % make sure we don't have something else assigned to 'i'
	sens_phase = -mataa_hilbert(sens_spl/20); % phase in radians
	
	sens_p = 10.^(sens_spl/20).*exp(i*sens_phase); % complex fourier spectrum of sensor transfer function
	
	% make up second half of fourier spectrum:
	% first entry: DC component ( set this to NaN )
	% first half = sens_p
	% middle point belongs to both halves
	% second half = conj(fliplr(sens_p)), because the impulse response of the sensor is real
	
	sens_p = reshape(sens_p,1,length(sens_p));
	P = [ NaN sens_p conj(fliplr(sens_p(1:end-1))) ];

	% remove components with f > fMax of f < fMin from h
	H = mataa_realFT(h,t); % get the 'real' half of the fourier specturm of h
		
	H(f>fMax) = 0; % remove components with f>fMax
	H(f<fMin) = 0; % remove components with f<fMin
	H = reshape(H,1,length(H));
	H = [ 0 H conj(fliplr(H(1:end-1))) ]; % make up full fourier spectrum of h
	
	% normalize H by P (deconvolve h from impulse response of sensor):
	H_corr = H ./ P;
	
	H_corr(1) = 0; % 'repair' the NaN DC-value, remember: P(1)=NaN )
	h_corr = real(ifft(H_corr));
	
	h_corr = h_corr(:);
	t = t(:);

	disp('...done.');

else
	disp(sprintf('WARNING: Could not correct for sensor characteristics, because the file %s is not available.',sens_name))
	h_corr = h;
end

cd(oldPath)
