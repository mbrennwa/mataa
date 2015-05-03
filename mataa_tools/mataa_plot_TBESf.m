function mataa_plot_TBESf (f,tau,A,ARange,tauRange,annote);

% function mataa_plot_TBESf (f,tau,A,ARange,tauRange,annote);
%
% DESCRIPTION:
% Plot tone burst energy storage data (as obtained from mataa_IR_to_TBES(...) in a 3D diagram using slices of constant frequency t.
%
% INPUT:
% f,tau,A: see description of output of mataa_IR_to_TBES
% ARange: range of A axis
% annote: annotations to the plot title (string, optional)
% 
% EXAMPLE:
% > [h,t] = mataa_IR_demo ('FE108');
% > f = logspace (2,4,50);
% > [A,tau,f] = mataa_IR_to_TBES (h,t,f);
% > mataa_plot_TBESf (f,tau,A,40,8,'FE108');
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
% Copyright (C) 2015 Matthias S. Brennwald.
% Contact: info@audioroot.net
% Further information: http://www.audioroot.net/MATAA

color = mataa_settings('plotColor');
figure(mataa_settings('plotWindow_TBES'));
mataa_plot_defaults;

if ~exist('annote')
    annote = '';
end
if length(annote) > 0
    if ~strcmp(annote,''), annote = [' (' annote ')' ]; end;
end


% make sure we've got column vectors:
f = f(:);
tau = tau(:);
A = A(:);

ARange = abs(ARange);

if exist('OCTAVE_VERSION') % use Octave plotting

	if strcmp (tolower(graphics_toolkit),'fltk') % Use Octave with FLTK graphics toolkit
		% we're running Octave with FLTK graphics backend, which allows plotting waterfalls similarly to Matlab (see below)
		ff = unique (f);
    	for n = 1:length(ff) % loop to plot each slice
    		i = find(f==ff(n));
    		xi = f(i);
    		yi = tau(i);
    		zi = A(i);
    		
    		k = find (yi <= tauRange);
    		xi = xi(k);
    		yi = yi(k);
    		zi = zi(k);
    		
    		% append values make closed patch / path
    		xi = [ xi(1) ; xi(:) ; xi(end) ];
    		yi = [ yi(1) ; yi(:) ; yi(end) ];
    		z0 = min ([-ARange;zi(:)]);
    		zi = [ z0 ; zi(:) ; z0 ];
    		
    		% construct vertices matrix (list of vertices; x/y/z coordinates):
    		V = [ xi(:) yi(:) zi(:) ];
    
    		% construct faces matrix (list of vertices defining triangles that make up the patch, values in list correspond to line in V matrix):
			F = [ 1:length(xi) ];
			
		    % plot slice
    		p = patch ('Vertices',V, 'Faces',F, 'Edgecolor','k', 'Facecolor',[1 1 1] , 'Linestyle','-' ); hold on; % fill slice
    		
    	end % plotting slices

		hold off
		set(gca,'XScale','log');
		set(gca,'YDir','reverse')
		grid on
		set(gca,'Box','off'); % should be off anyway, but...
		view(12,30)
		
		r = [ min(f) max(f) 0 tauRange max(A)-ARange max(A) ];
		axis ( r );
		
    	% plot 'frame in the back':
    	l=line([r(1) r(2)], [r(3) r(3)], [r(6) r(6)]); set(l,'Color','k');
    	l=line([r(1) r(1)], [r(3) r(4)], [r(6) r(6)]); set(l,'Color','k');
    	l=line([r(1) r(1)], [r(3) r(4)], [r(5) r(5)]); set(l,'Color','k');
    	l=line([r(1) r(1)], [r(3) r(3)], [r(5) r(6)]); set(l,'Color','k');
    	l=line([r(2) r(2)], [r(3) r(3)], [r(5) r(6)]); set(l,'Color','k');
		
	else
		% we're running Octave without FLTK graphics backend (propably GnuPlot), which does a bad job in plotting waterfalls like CLIO or MLSSA.
		error ('mataa_plot_TBESf: TBES plotting using Octave without FLTK graphics backend is not available. Ask a guru to implement this.')
			
	end % Octave plotting
	
else % We're running Matlab
    error ('mataa_plot_TBESf: TBES plotting using Matlab is not available. Ask a guru to implement this.')
end % Matlab plotting

title(['MATAA: tone burst energy decay' annote]);
xlabel('Frequency (Hz)');
ylabel('Cycles');
zlabel('SPL (dB)');
