function mataa_plot_ETC_lin (etc,t,annote);

% function mataa_plot_ETC_lin (etc,t,annote);
%
% DESCRIPTION:
% Plots the energy-time-curve (ETC) etc(t), using a linear y-axis scale.
% 
% INPUT:
% etc: values of the energy-time curve (vector)
% t: time values (vector)
% annote (optional): annotation to the plot title (string)
% 
% OUTPUT:
% (none)
%
% EXAMPLE:
% > t = [0:100]/1000; h = sin(200*t).*exp(-70*t);
% > etc = mataa_IR_to_ETC(h,t);
% > mataa_plot_ETC(t,etc, 'damped sine');
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

if ~exist('annote','var')
    annote = '';
end

if length (annote) > 0
    annote = sprintf (' (%s)',annote);
end

annote = sprintf ('MATAA: energy-time curve%s',annote);

h = mataa_plot_one (t,etc,mataa_settings ('plotWindow_ETC'),annote,'Time (s)','ETC (linear)');
