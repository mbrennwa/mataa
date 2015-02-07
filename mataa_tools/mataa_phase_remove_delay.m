function phase = mataa_phase_remove_delay (phase,f,delay);

% function [phase,f] = mataa_phase_remove_delay (phase,delay);
%
% DESCRIPTION:
% This function removes excess phase due to time delay.
%
% INPUT:
% phase: phase, including excess phase due to time delay (unwrapped, in degrees)
% f: frequency coordinates of phase (in Hz)
% delay: time delay to be removed from the phase (in seconds)
%
% OUTPUT:
% phase: phase with excess phase corresponding to delay removed (unwrapped, in degrees)
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
% Further information: http://www.audioroot.net/MATAA

exPhase = -2*pi*f*delay; % see D'Appolito, J.: Testing Loudspeakers, page 111
phase = phase - exPhase;
