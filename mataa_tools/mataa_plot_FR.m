function mataa_plot_FR (mag,phase,f,annote,fNorm,phaseUnwrap);

% function mataa_plot_FR (mag,phase,f,annote,fNorm,phaseUnwrap);
%
% DESCRIPTION:
% Plots frequency response magnitude, and phase (optional)
%
% INPUT:
% mag: magnitude of frequency response (in dB)
% phase (optional): phase of frequency response (in degrees). If you don't want to plot phase, but other optional arguments below are required, use phase = [].
% f: frequency coordinates of mag and phase (in Hz)
% annote (optional): text note to be added to the plot title. If you don't want to add a note, but other optional arguments below are required, use annote = ''.
% fNorm (optional): frequency to which the magnitude plot is normalised. If you don't want to normalise the plot, but other optional arguments below are required, use fNorm = [].
% phaseUnwrap (optional): if phaseUnwrap is not zero, the phase is unwraped (so that discontinuities at +/- 180 deg. are avoided). Otherwise, phase is wrapped to +/- 180 deg.
%
% EXAMPLE(S):
% > [h,t] = mataa_IR_demo; 
% > [mag,phase,f] = mataa_IR_to_FR(h,t,1/12);
% > mataa_plot_FR(mag,[],f); % plain vanilla plot of magnitude vs. frequency (without phase)
% > mataa_plot_FR(mag,[],f,'demo',1000); % plots magnitude with an annotation to the plot title and normalizes mag by mag(f=1000).
% > mataa_plot_FR(mag,phase,f,'demo again',80,1); % plots magnitude and phase with an annotation to the plot title. Magnitude is normalised such that mag(f=80) = 0 dB, and phase is unwrapped.
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

if ~exist ('annote')
    annote = '';
end

if length (annote) > 0
    annote = sprintf (' (%s)',annote);
end

if ~exist('fNorm')
    fNorm = [];
end

if ~isempty(fNorm)
    mag = mag - mataa_interp (f,mag,fNorm);
    y1lab = sprintf('Magnitude (dB, rel. %i Hz)',fNorm);
else
    y1lab = 'Magnitude (dB)';
end

if ~exist('phaseUnwrap')
    phaseUnwrap = 0;
end

annote = sprintf ('MATAA: frequency response%s',annote);

if phaseUnwrap
        phase = unwrap(phase/180*pi)/pi*180;
else
    phase = mod (phase+180,360)-180;
end

h = mataa_plot_two_logX (f,mag,phase,mataa_settings ('plotWindow_FR'),annote,'Frequency (Hz)',y1lab,'Phase (deg.)');

if ~isnan(h(2))
    if ~phaseUnwrap
        r = axis(h(2)); r([3,4]) = [-180 180]; axis(r);
        set (h(2),'ytick',[-180:90:180]);
    end
end
