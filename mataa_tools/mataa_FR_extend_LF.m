function [mag,phase,f] = mataa_FR_extend_LF (fh,mh,ph,fl,ml,pl,f1,f2);;

% function [mag,phase,f] = mataa_FR_extend_LF (fh,mh,ph,fl,ml,pl,f1,f2);;
%
% DESCRIPTION:
% Extend frequency response (e.g. from an anechoic analysis of a loudspeaker impulse response measured in the far field) with low-frequency data (e.g. from a near-field measurement). The frequency ranges of the two frequency responses need to overlap, and the common data in the frequency range [f1,f2] is used to determine the offsets in the magnitude and phase of the two frequency-response data sets. The low-frequency magnitude and phase (ml, pl) is adjusted to fit the high-frequency data (mh, ph). The phase data (ph, pl) may either be wrapped (e.g. to a range of -180..+180 deg) or unwrapped. After adjusting the relative offsets, the resulting response in the overlap band is computed as the weighted mean of the low and high frequency data, where the weight of the high-frequency data increases linearly from 0 at f1 to 1 at f2 (and vice versa for the low-frequency data).
%
% INPUT:
% mh, ph, fh: magnitude (dB), phase (deg.) and frequency (Hz) data of the frequency response covering the high-frequency range
% ml, pl, fl: magnitude (dB), phase (deg.) and frequency (Hz) data of the frequency response covering the low-frequency range
% f1, f2: [f1,f2] is the frequency range used to determine the offsets of the low-frequency magnitude and phase (ml, pl) relative to the high-frequency data (mh, ph).
%
% OUTPUT:
% mag, phase, f: magnitude (dB), phase (deg, unwrapped) and frequency (Hz) of the combined frequency response. The data with f > f2 are identical to (mh,ph,fh), those with f < f1 correspond to (ml,pl,fl) with the magnitude and phase offsets removed. The data in the range [f1,f2] corresponds to the combination of the data of both data sets.
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
% Further information: http://www.audioroot.net/MATAA

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
ml = ml - delta_m;
% match phase, remove excess phase by looking at frequency range f1...f2:
% exPhase = -2*pi*f*delay;

ff = unique ([fh(ih);fl(il)]);
pph = interp1 (fh(ih),ph(ih),ff);
ppl = interp1 (fl(il),pl(il),ff);
rp  = ppl./pph; rp = mean (rp(~isna(rp)));
pl = pl/rp;

%%% if length(ih) == 1
%%% 	pol_h = [ 0 ph(ih)/fh(ih)];
%%% else
%%% 	pol_h = polyfit (fh(ih),ph(ih),1);
%%% end
%%% if length(ih) == 1
%%% 	pol_l = [ 0 pl(il)/fl(il)];
%%% else
%%% 	pol_l = polyfit (fl(il),pl(il),1);
%%% end
%%% ph = ph - polyval(pol_h,fh);
%%% pl = pl - polyval(pol_h,fl);


% construct m, p, and f:

% A. low-frequency part (frequency < f1):
i = find (fl < f1);
mA = ml(i); pA = pl(i); fA = fl(i); % data with f < f1

% B. overlap part (frequency in range f1...f2):
% (compute result as linear combination of mh/ph and ml/pl)
il = find (fl >= f1 & fl <= f2);
ih = find (fh >= f1 & fh <= f2);
fB = unique ( [ fl(il)(:) ; fh(ih)(:) ] );
ML = interp1 (fl,ml,fB);
PL = interp1 (fl,pl,fB);
MH = interp1 (fh,mh,fB);
PH = interp1 (fh,ph,fB);
a  = (fB-min(fB)) / (max(fB)-min(fB));
mB = a .* MH + (1-a) .* ML;
pB = a .* PH + (1-a) .* PL;

% mB = [ ml(il)(:) ; mh(ih)(:) ]; pB = [ pl(il)(:) ; ph(ih)(:) ]; fB = [ fl(il)(:) ; fh(ih)(:) ]; % data with f in [f1,f2]

% C. high-frequeny part (frequency > f2):
i = find (fh > f2);
mC = mh(i); pC = ph(i); fC = fh(i); % data with f > f2
mag = [ mA(:) ; mB(:) ; mC(:) ]; phase = [ pA(:) ; pB(:) ; pC(:) ]; f = [ fA(:) ; fB(:) ; fC(:) ]; % complete data

% make sure everything is nicely sorted with increasing frequency:
[f,i] = sort (f);
mag = mag(i); phase = phase(i);