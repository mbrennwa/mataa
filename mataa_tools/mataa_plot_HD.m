function mataa_plot_HD(kn,annote);

% function mataa_plot_HD(kn);
%
% DESCRIPTION:
% This function plots the harmonic distortion spectrum in kn.
%
% INPUT:
% kn = [ k1 k2 k3 ... kn ] is the normalised distortion spectrum.
% k1 corresponds to the fundamental frequency or first harmonic (k1 = 1, not plotted), k2 the component of second harmonic relative to the fundamental, k3 that of the third harmonic, etc.
% annote (optional): optional annotation to be added to the plot title
%
% EXAMPLE:
% > [thd,k] = mataa_measure_thd(1000,1,96000); % measure THD and harmonic distortion spectrum
% > mataa_plot_HD(k,'f0: 1kHz'); % plot the distortion spectrum
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
% first version: 28. November 2006, Matthias Brennwald

if ~exist('annote')
    annote = '';
end

if length(annote) > 0
    annote = [' (' annote ')' ];
end

figure(mataa_settings('plotWindow_HD'));
mataa_plot_defaults;

holdstate=ishold;

style=mataa_settings('plotStyle');
style1 = [ style(find(isletter(style))) '-' ];
if exist('OCTAVE_VERSION')
    style2 = [ style(find(isletter(style))) '*' ];
else
    style2 = [ style(find(isletter(style))) '.' ];
end

for i=2:length(kn)
    y = kn(i)*100; % convert to percent
    plot([i i],[0 y],style1,i,y,style2); hold on
end

r=[ 1.5 length(kn)+0.5 0 max(kn(2:end))*120 ]; axis(r);
title(['MATAA: harmonic distortion spectrum' annote]);
ylabel('k_n (%)');
xlabel('n');

if ~holdstate
    hold off
end