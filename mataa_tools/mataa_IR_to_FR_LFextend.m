function [mag,phase,f,unit] = mataa_IR_to_FR_LFextend (h,t,t1,t2,t3,N,smooth_interval,unit);

% function [mag,phase,f,unit] = mataa_IR_to_FR_LFextend (h,t,t1,t2,t3,N,smooth_interval,unit);
%
% DESCRIPTION:
% Calculate frequency response (magnitude in dB and phase in degrees) of a loudspeaker with impulse response h(t) in two steps: first, the anechoic part (t < T0) is windowed and fourier transformed. Then, low-frequency bins in the range f0...1/T0 are added by using the part of the impulse response after T0 (the low-frequency response is therefore not anechoic).
%
% INPUT:
% h: impulse response (in volts)
% t: time coordinates of samples in h (vector, in seconds) or sampling rate of h (scalar, in Hz)
% t1, t2, t3: time ranges of the anechoic and the following echoic parts, relative to the first value in t. [t1,t2] is the time range used to calculate the anechoic frequency response, [t1,t3] the time range used to extend the frequency response towards lower frequencies (echoic part).
% N: number of frequency-response values to calculate in echoic frequency range
% smooth_interval (optional): if specified, the frequency response is smoothed over the octave interval smooth_interval.
% unit: see mataa_IR_to_FR
%
% OUTPUT:
% mag: magnitude of frequency response (in dB)
% phase: phase of frequency response (in degrees). This is the TOTAL phase including the 'excess phase' due to (possible) time delay of h(h). phase is unwrapped (i.e. it is not limited to +/-180 degrees, and there are no discontinuities at +/- 180 deg.)
% f: frequency coordinates of mag and phase
% unit: see mataa_IR_to_FR
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
% Further information: http://www.audioroot.net/MATAA.html

if ~exist ('unit','var')
	warning ("mataa_IR_to_FR_LFextend: unit of input data not given. Assuming unit = 'FS' (digital full scale ranging from -1 to +1).")
	unit = 'FS';
end

if ~exist ('smooth_interval','var')
	smooth_interval = [];
end

if isscalar(t)
    t = [0:1/t:(length(h)-1)/t]';
end

% convert t1, t2 and t3 to absolute time values:
t1 = t1 + t(1);
t2 = t2 + t(1);
t3 = t3 + t(1);

% frequency response of the anechoic part:
i = find (t >= t1 & t <= t2);
s = h(i); ts = t(i);
s = s - mean(s); % remove DC component
[m1,p1,f1] = mataa_IR_to_FR (s,ts,smooth_interval,unit);

% frequency response including the echoic part
f2 = logspace (log10(1/(t3-t1)),log10(f1(1)),N+1);
f2 = f2(1:end-1);
p2 = repmat (NaN,size(f2));
m2 = repmat (NaN,size(f2));
for k = 1:N
    i = find (t >= t1 & t <=t1+ 1/f2(k));
    s = h(i); ts = t(i);
    s = s - mean(s); % remove DC component
    [mm,pp,ff,unit_m] = mataa_IR_to_FR (s,ts,smooth_interval,unit);
    f2(k) = ff(1);
    m2(k) = mm(1);
    p2(k) = pp(1);
end

f = [ f2(:) ; f1(:) ]';
mag = [ m2(:) ; m1(:) ]';
phase = [ p2(:) ; p1(:) ]';
unit = unit_m;
