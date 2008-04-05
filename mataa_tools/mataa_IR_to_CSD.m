function [spl,f,d] = mataa_IR_to_CSD(h,t,T,smooth_interval);

% function [spl,f,t] = mataa_IR_to_CSD(h,t,T,smooth_interval);
%
% DESCRIPTION:
% This function calculates cumulative spectral decay (CSD) data (SPL-responses spl at frequencies f and delay times d).
%
% INPUT:
% h: values impulse response (vector)
% t: time values of samples in h (vector, in seconds) or sampling rate of h (scalar, in Hz)
% T: desired delay times (should be evenly spaced)
% smooth_interval (optional): if supplied, the SPL curves are smoothed using mataa_IR_to_FR_smooth
%
% OUTPUT:
% spl: CSD data (dB)
% f: frequency (Hz)
% d: delay of CSD data (seconds)
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
% first version: 24. November 2006, Matthias Brennwald

if isscalar(t)
    t = [0:1/t:(length(h)-1)/t];
end

% make sure we've got column vectors:
h = h(:);
t = t(:);
T = T(:);

fs=(length(t)-1)/(max(t)-min(t));

t = t-t(1); % shift impulse response to zero-based time

spl=[]; f=[]; d=[];
dT=T(2)-T(1);

for n=1:length(T)
	% construct a time window to (smoothly) cut off the beginning of the impulse response:	
	window = repmat(NaN,length(h),1);
	window(t<T(n)-dT/2) = 0;
	window(t>T(n)+dT/2) = 1;
	i = find(isnan(window)); 
	window(i)=0.5+0.5*sin(pi*(t(i)-T(n))/dT); % smooth transition from 0 to 1
	h = window.*h;

	if T(n) <= max(t)
		if exist('smooth_interval')
			[splI,phase,fI] = mataa_IR_to_FR(h,t,smooth_interval);
		else
			[splI,phase,fI] = mataa_IR_to_FR(h,t);
		end
		
		clear phase;
	   
		% throw away data with f < fMin
		fMin = 1/(max(t)-(T(n)));
		i = find( fI >= fMin );
		fI = fI(i); splI = splI(i);
	
		% make sure we've got column vectors:
		splI = splI(:);
		fI = fI(:);
	
		% add the data to the output:
		f   = [ f   ; fI ];
		spl = [ spl ; splI ];
		d   = [ d   ; repmat(T(n),size(fI)) ];
    end
%	else
%		T(n) = NaN;
%	end
end
