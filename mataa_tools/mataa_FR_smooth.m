function [mag,phase,f] = mataa_FR_smooth (mag,phase,f,smooth_interval);

% function [mag,phase,f] = mataa_FR_smooth (mag,phase,f,smooth_interval);
%
% DESCRIPTION:
% Smooth frequency response in octave bands.
%
% INPUT:
% mag: magnitude data
% phase: phase data
% f: frequency
% smooth_interval: width of octave band used for smoothing
%
% OUTPUT:
% mag: smoothed frequency response (magnitude)
% phase: smoothed frequency response (phase)
% f: frequency values of smoothed frequency response data
%
% EXAMPLE:
% > [h,t] = mataa_IR_demo; 
% > [mag,phase,f] = mataa_IR_to_FR(h,t); % calculates magnitude(f) and phase(f)
% > [magS,phaseS,fS] = mataa_FR_smooth(mag,phase,f,1/4); % smooth to 1/4 octave resolution
% > semilogx ( f,mag , fS,magS ); % plot raw and smoothed data
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
% Copyright (C) 2015 Matthias S. Brennwald.
% Contact: info@audioroot.net
% Further information: http://www.audioroot.net/MATAA

% fractional octave between last and second-last data point:
Nf  = log2 (f(end)/f(end-1));

% number of points corresponding to smooth_interval:
Ns = round (smooth_interval / Nf);

% smooth the log-f data:
if Ns > 1 % otherwise no smoothing is required
	
	No = log2 (f(end)/f(1)); % number of octaves covered by full data set
	NL = round (No/Nf); % number of data points required for log-interpolation to capture the original data at full resolution
	
	% interpolate to log-distributed frequency values:
	f0    = f;
	f     = logspace(log10(f0(1)),log10(f0(end)),NL);
	mag   = interp1 (f0,mag,f,'extrap');
	phase = interp1 (f0,phase,f,'extrap');
        
    % construct sliding window W with effective width Ns:
    W  = linspace (1/Ns,1,round(0.2*Ns));
    W  = [ W repmat(1,1,round(0.8*Ns)) fliplr(W) ];
    W = W / sum(W); % normalize
    NW = length(W);
    % convolve mag and phase with W:
    % mag   = conv ([ repmat(mag(1),1,NW) mag repmat(mag(end),1,NW) ],W,'same')(NW+1:end-NW);
    % phase = conv ([ repmat(phase(1),1,NW) phase repmat(phase(end),1,NW) ],W,'same')(NW+1:end-NW);
    M0 = mag;
    P0 = phase;
    mag   = fftconv ([ repmat(mag(1),1,NW) mag repmat(mag(end),1,NW) ],W);
    phase = fftconv ([ repmat(phase(1),1,NW) phase repmat(phase(end),1,NW) ],W);
    a = round(1.5*NW);
    b = 3*NW-a;
    mag = mag(a:end-b);
    phase = phase(a:end-b);
end