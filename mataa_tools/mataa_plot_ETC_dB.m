function mataa_plot_ETC_dB (etc,t,annote,dB_range);

% function mataa_plot_ETC_log (etc,t,annote,dB_range);
%
% DESCRIPTION:
% Same as mataa_plot_ETC, but uses a dB scale for the vertical axis.
% The 'dB_range' parameter (optional) can be given to specify the dB range to be plotted. If not specified, a default value of 60 dB is used
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

if ~exist('annote')
    annote = '';
end

if length (annote) > 0
    annote = sprintf (' (%s)',annote);
end

annote = sprintf ('MATAA: energy-time curve%s',annote);
etc = 20*log(etc);

h = mataa_plot_one (t,etc,mataa_settings ('plotWindow_ETC'),annote,'Time (s)','ETC (dB)');

if ~exist('dB_range')
    dB_range=60;
end

r = axis (h); r(3) = max(etc)-dB_range;
figure (get(h,'parent')); % make sure the right figure window is in front
axis (r);
