function [mag,phase,f] = mataa_FR_extend_LF (fh,mh,ph,fl,ml,pl,f1,f2);;

% function [mag,phase,f] = mataa_FR_extend_LF (fh,mh,ph,fl,ml,pl,f1,f2);;
%
% DESCRIPTION:
% Extend frequency response (e.g. from an anechoic analysis of a loudspeaker impulse response measured in the far field) with low-frequency data (e.g. from a near-field measurement). The frequency ranges of the two frequency responses need to overlap, and the common data in the frequency range [f1,f2] is used to determine the offsets in the magnitude and phase of the two frequency-response data sets. The low-frequency magnitude and phase (ml, pl) is adjusted to fit the high-frequency data (mh, ph). The phase data (ph, pl) may either be wrapped (e.g. to a range of -180..+180 deg) or unwrapped.
%
% INPUT:
% mh, ph, fh: magnitude (dB), phase (deg.) and frequency (Hz) data of the frequency response covering the high-frequency range
% ml, pl, fl: magnitude (dB), phase (deg.) and frequency (Hz) data of the frequency response covering the low-frequency range
% f1, f2: [f1,f2] is the frequency range used to determine the offsets of the low-frequency magnitude and phase (ml, pl) relative to the high-frequency data (mh, ph).
%
% OUTPUT:
% mag, phase, f: magnitude (dB), phase (deg, unwrapped) and frequency (Hz) of the combined frequency response. The data with f > f2 are identical to (mh,ph,fh), those with f < f1 correspond to (ml,pl,fl) with the magnitude and phase offsets removed. The data in the range [f1,f2] corresponds to the combination of the data of both data sets, where (ml,pl) values are corrected for their offsets relative to the (mh,ph) values.
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
% Copyright (C) 2009 Matthias S. Brennwald.
% Contact: info@audioroot.net
% Further information: http://www.audioroot.net/MATAA.html

ph = unwrap (ph/180*pi)/pi*180; % make sure ph and pl are unwrapped
pl = unwrap (pl/180*pi)/pi*180;

if min(fh) > max(fl)
    error ("mataa_FR_extend_LF: the frequency ranges of the two data sets do not overlap.")
end

if f2 <= f1
    warning ("mataa_FR_extend_LF: f1 should be lower than f2. Exchanging the two values...");
    x = f1; f1 = f2; f2 = x; clear x;
end

if f1 < min(fh)
    warning ("mataa_FR_extend_LF: f1 is lower than the lowest frequency of the high-frequency data set. Adjusting f1 accordingly.")
    f1 = min(fh);
end

if f2 > max(fl)
    warning ("mataa_FR_extend_LF: f2 is higher than the highest frequency of the low-frequency data set. Adjusting f2 accordingly.")
    f2 = max(fl);
end

% determine and subtract offset in (ml,pl) relative to (mh,ph) in [f1,f2]:
ih = find (fh >= f1 & fh <= f2);
il = find (fl >= f1 & fl <= f2);
ff = union (fh(ih),fl(il));
mmh = interp1 (fh,mh,ff); pph = interp1 (fh,ph,ff);
mml = interp1 (fl,ml,ff); ppl = interp1 (fl,pl,ff);
delta_m = mean (mml-mmh);
delta_p = mean (ppl-pph);
ml = ml - delta_m;
pl = pl - delta_p;

% construct m, p, and f:
i = find (fl < f1);
mA = ml(i); pA = pl(i); fA = fl(i); % data with f < f1
il = find (fl >= f1 & fl <= f2);
ih = find (fh >= f1 & fh <= f2);
mB = [ ml(il) ; mh(ih) ]; pB = [ pl(il) ; ph(ih) ]; fB = [ fl(il) ; fh(ih) ]; % data with f in [f1,f2]
i = find (fh > f2);
mC = mh(i); pC = ph(i); fC = fh(i); % data with f > f2
mag = [ mA ; mB ; mC ]; phase = [ pA ; pB ; pC ]; f = [ fA ; fB ; fC ]; % complete data

% make sure everything is nicely sorted with increasing frequency:
[f,i] = sort (f);
mag = mag(i); phase = phase(i);

