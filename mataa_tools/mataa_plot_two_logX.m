function h = mataa_plot_two_logX (x,y1,y2,figNum,plottit,xtit,y1tit,y2tit);

% function h = mataa_plot_two_log (x,y1,y2,figNum,plottit,xtit,y1tit,y2tit);
%
% DESCRIPTION:
% Same as mataa_plot_two, but with logarithmic x axes.
%
% INPUT:
% (see mataa_plot_two)
%
% OUTPUT:
% (see mataa_plot_two)
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
% Copyright (C) 2007, 2008 Matthias S. Brennwald.
% Contact: info@audioroot.net
% Further information: http://www.audioroot.net/MATAA.html

h = mataa_plot_two (x,y1,y2,figNum,plottit,xtit,y1tit,y2tit);

set (h(1),'xscale','log');
if ~isnan (h(2))
    set (h(2),'xscale','log');
end
