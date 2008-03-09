function mataa_plot_SR(h,t,annote);

% function mataa_plot_SR(h,t,annote);
%
% DESCRIPTION:
% This function plots the step response h(t).
%
% INPUT:
% h: step response samples
% t: time coordinates of response response samples (vector), or, alternatively, the sampling frequency of h(t) (scalar)
% annote (optional): text note to be added to the plot title.
%
% EXAMPLE:
% > [h,t] = mataa_IR_demo;
% > [h,t] = mataa_IR_to_SR(h,t);
% > mataa_plot_SR(h,t,'demo step response');
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
% 26. Nov. 2006 (Matthias Brennwald): first version

if ~exist('annote')
    annote = '';
end

if length (annote) > 0
    annote = sprintf (' (%s)',annote);
end

annote = sprintf ('MATAA: Step response%s',annote);

mataa_plot_time_signal (h,t,annote,'Step response',mataa_settings ('plotWindow_SR'));