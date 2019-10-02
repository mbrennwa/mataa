function mataa_plot_HD (kn,annote);

% function mataa_plot_HD (kn, annote);
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
% > HD = mataa_measure_HD_noise ( 1000,1,44100,10,0.2 ); % measure harmonic distortion spectrum
% > mataa_plot_HD(HD(1,:),'f0: 1kHz'); % plot the distortion spectrum
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

if ~exist('annote','var')
    annote = '';
end

if length(annote) > 0
    annote = [' (' annote ')' ];
end

figure(mataa_settings('plotWindow_HD'));
mataa_plot_defaults;

set (0,'defaultaxesposition', [0.05, 0.1, 0.9, 0.85]) 

holdstate=ishold;

yp_min = 1E-10;

for i=2:length(kn)
	yp  = kn(i)*100; % convert to percent
	ydB = 20*log10(kn(i)); % convert to dB
	[ax, h1, h2] = plotyy ([i i],[yp_min yp], i,ydB ); hold on
	% plot([i i],[0 y],style1,i,y,style2); hold on

	set (h1,'linestyle','-','color','k','linewidth',3)		
	set (h2,'linestyle','none','marker','.','markersize',30,'color','k')		

end

set(ax,'position',[0.13 0.11 0.73 0.77])
set (ax,{'ycolor'},{'k';'k'});
set (ax(1),'yscale','log' );
set (ax(2),'xtick',[]);

r1 = [ 1.5 length(kn)+0.5 0.0001 100 ]; axis(ax(1),r1);
r2 = r1; r2(3:4) = 20*log10(r1(3:4)/100); axis(ax(2),r2);
title(['MATAA: harmonic distortion spectrum' annote]);
ylabel(ax(1),'k_n (%)');
ylabel(ax(2),'k_n (dB)');
xlabel('n');

if ~holdstate
    hold off
end
