function mataa_plot_impedance(mag,phase,f,annote);

% function mataa_plot_impedance(mag,phase,f,annote);
%
% DESCRIPTION:
% Plots impedance (magnitude and phase) versus frequency.
%
% INPUT:
% mag: impedance magnitude (Ohm)
% phase: impedance phase (degrees)
% f: frequency (Hz)
% annote (optional): text note to be added to the plot title.
%
% OUTPUT:
% (none)
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
% 27. December 2007 (Matthias Brennwald): rewrote most of the code to eliminate specific code for Octave/gnuplot. The new code does not work with outdated versions of Octave (Octave 3.0 or later is recommended).
% 25. November 2006 (Matthias Brennwald): first version

if ~exist ('annote')
    annote = '';
end

if length (annote) > 0
    annote = sprintf (' (%s)',annote);
end

annote = sprintf ('MATAA: impedance%s',annote);

h = mataa_plot_two_logX (f,mag,mod (phase+180,360)-180,mataa_settings ('plotWindow_impedance'),annote,'Frequency (Hz)','Magnitude (Ohm)','Phase (deg.)');

if ~isnan(h(2))
    r = axis(h(2)); r([3,4]) = [-180 180]; axis(r);
    set (h(2),'ytick',[-180:90:180]);
end