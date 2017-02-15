function [mlsvec,mlsfs,stimulus_amp,mlsdf] = mataa_import_mlssa (File,Outfile,Withir);

%
% Reads a MLSSA .TIM or .FRQ file and extracts all data from it. Note that this function has been designed using Matlab only (i.e. it might not work as well with Octave).
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
% Further information: http://www.audioroot.net/MATAA
%
% The program is based on code written by Peter Svensson (svensson[at]iet.ntnu.no) available at http://www.iet.ntnu.no/~svensson/readmls.m. Peter Svensson explicitly agreed to provide his work for inclusion in MATAA.

