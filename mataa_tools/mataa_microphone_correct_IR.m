function [h_corr,t] = mataa_microphone_correct_IR(mic_name,h,t)

% function [h,t] = mataa_microphone_correct_IR(mic_name,h,t)
%
% DESCRIPTION:
% This function corrects h(t) from the transfer function of the specified microphone
% the phase response of the microphone are calculated by assuming the microphone to be minimum phase
% frequency components outside the range of the specified microphone frequency response are set to zero
% 
% INPUT:
% mic_name: name of microphone
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
% Copyright (C) 2006 Matthias S. Brennwald.
% Contact: info@audioroot.net
% Further information: http://www.audioroot.net/MATAA.html
%
% HISTORY:
% first version: 12. November 2006, Matthias Brennwald

if isscalar(t)
    t = [0:1/t:(length(h)-1)/t];
end

oldPath = pwd;
cd(mataa_path('microphone'));

mic_name = [ mic_name '_transfer.txt' ];

if exist(mic_name)==2
	
	
	if exist('OCTAVE_VERSION')
		more('off'),
	end
	
	disp(sprintf('Correcting impulse response for microphone characteristics using data from the file %s (this may take a while)...',mic_name));
	
	h = h(:);
	if mod(length(h),2)
	   h = h(1:end-1);
	   t = t(1:end-1);
    end
    
	x=load(mic_name);
	f0 = x(:,1);
	mic_spl_0 = x(:,2);
	clear x
	
	fMax=max(f0); fMin=min(f0); % we'll need these further below
	
	T = max(t)-min(t);
	f = [1/T:1/T:length(t)/2*1/T];
	clear T
		
	mic_spl=repmat(NaN,length(f),1);
	for i=1:length(f);
		mic_spl(i) = mataa_interp(f0,mic_spl_0,f(i));	
	end
	
	
	% calculate minimum phase of microphone:
	i = sqrt(-1); % make sure we don't have something else assigned to 'i'
	mic_phase = -mataa_hilbert(mic_spl/20); % phase in radians
	
	mic_p = 10.^(mic_spl/20).*exp(i*mic_phase); % complex fourier spectrum of microphone transfer function
	
	% make up second half of fourier spectrum:
	% first entry: DC component ( set this to NaN )
	% first half = mic_p
	% middle point belongs to both halves
	% second half = conj(fliplr(mic_p)), because the impulse response of the microphone is real
	
	mic_p = reshape(mic_p,1,length(mic_p));
	P = [ NaN mic_p conj(fliplr(mic_p(1:end-1))) ];

	% remove components with f > fMax of f < fMin from h
	H = mataa_realFT(h,t); % get the 'real' half of the fourier specturm of h
		
	H(f>fMax) = 0; % remove components with f>fMax
	H(f<fMin) = 0; % remove components with f<fMin
	H = reshape(H,1,length(H));
	H = [ 0 H conj(fliplr(H(1:end-1))) ]; % make up full fourier spectrum of h
	
	% normalize H by P (deconvolve h from impulse response of microphone):
	H_corr = H ./ P;
	
	H_corr(1) = 0; % 'repair' the NaN DC-value, remember: P(1)=NaN )
	h_corr = real(ifft(H_corr));
	
	h_corr = h_corr(:)*length(h)/2;

	disp('...done.');

else
	disp(sprintf('WARNING: Could not correct for microphone characteristics, because the file %s is not available.',mic_name))
	h_corr = h;
end

cd(oldPath)