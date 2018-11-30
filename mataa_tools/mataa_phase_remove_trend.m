function [phase,delay] = mataa_phase_remove_trend (phase,f,f1,f2);

% function [phase,delay] = mataa_phase_remove_trend (phase,f,f1,f2);
%
% DESCRIPTION:
% Remove linear trend in phase(f), e.g. excess phase due to time delay.
%
% INPUT:
% phase: phase, including excess phase due to time delay (unwrapped, in degrees)
% f: frequency coordinates of phase (in Hz)
% f1, f2 (optional, in Hz): if both f1 and f2 are specified, the linear trend in phase(f1<f<f2) is removed from phase(f). If both f1 and f2 are not specified, the full range of f is used from trend analysis.
%
% OUTPUT:
% phase: phase with excess phase corresponding to delay removed (unwrapped, in degrees)
% delay: time delay corresponding the the removed phase trend (in seconds)
%
% EXAMPLE (remove excess phase and determine "flight time" of impulse response):
% [h,t,unit] = mataa_IR_demo ('FE108'); % load impulse response
% [mag,phase,f] = mataa_IR_to_FR(h,t,[],unit); % convert to frequency domain
% min_phase = mataa_minimum_phase (mag,f); % determine minimum phase (in degrees)
% ex_phase = phase - min_phase; % determine excess phase (phase = minimum-phase + excess-phase)
% [u,delay] = mataa_phase_remove_trend (ex_phase,f,1400,5000); % determine exess phase trend (ex_phase = -2pi x delay), and determine delay = "flight time"
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

i=[];

if exist('f1','var')
    if exist('f2','var')
        if f1 > f2
            ff = f2; f2 = f1; f1 = ff; clear ff;
        end
        i = find(f>=f1 & f<=f2);
    else
        error('mataa_phase_remove_trend: f2 not specified');
    end
else
    i = 1:length(f);
end

if isempty(i)
    error('mataa_phase_remove_trend: frequency range too small');
end

% determine delay corresponding to phase trend (excess phase, see D'Appolito, J.  (1998) Testing Loudspeakers, page 111)
p = polyfit(f(i),phase(i),1);
%%% delay = -p(1)/(2*pi);
delay = -p(1)/360;

% remove exess phase due to delay:
phase = mataa_phase_remove_delay(phase,f,delay);
