function mataa_plot_CSD(spl,f,d,spl_range,annote,options);

% function mataa_plot_CSD(spl,f,d,spl_range,annote,options);
%
% DESCRIPTION:
% Plot cumulative spectral decay (CSD) data from mataa_IR_to_CSD(...)
% ('waterfall plot'). The argument 'annote' is optional, and can be used to specify annotations to be added to the titles of the plots.
%
% INPUT:
% spl,f,d: see description of output of mataa_IR_to_CSD
% spl_range: the range covered on the y axis of the waterfall diagram (in dB)
% annote: annotations to the plot title (string, optional)
% options: plot options (sting or cell string containing multiple options, optional). Currently, the following options are available (for Octave 2.9.10 or newer):
%     options = 'contours' : plot contours of waterfall diagram below the waterfall
%     options = 'countours_only': plot contours (lines) only in a 2-D plot (this is essentially a sonogram)
%     options = 'sonogram': plot a sonogram in 2-D (this is very similar to 'contours_only', but fills the areas in between the contours with a solid color)
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
% 2. April 2008 (Matthias Brennwald): added 'sonogram' and 'contours_only' option (sonogram).
% 31. March 2008 (Matthias Brennwald): improved help text
% 27. December 2007 (Matthias Brennwald): removed gnuplot-specific code for Octave (this requires Octave 3.0 or later for proper operation -- nothing has changed for Matlab).
% 18. August 2007 (Matthias Brennwald): added plotting options
% 23. April 2007: added code to produce acceptable results with Octave 2.9.10 or newer (Octave 2.9.10 and newer use the Matlab-like plotting handles and axes).
% 9. April 2007: added a warning that Octave does not plot the most beautiful CSD
% first version: 7. November 2006, Matthias Brennwald


if ~exist('annote')
    annote = '';
end

if ~exist('options')
    options = '';
end

if length(annote) > 0
    if ~strcmp(annote,''), annote = [' (' annote ')' ]; end;
end

color = mataa_settings('plotColor');
figure(mataa_settings('plotWindow_CSD'));
mataa_plot_defaults;

% make sure we've got column vectors:
f = f(:);
spl = spl(:);
d = d(:);

scale = 0;
while scale > ceil(log10(max(d)))
	scale = scale-3;
end

spl = spl-max(spl);
spl(find(spl < -spl_range)) = -spl_range;

if exist('OCTAVE_VERSION')

% warning('mataa_plot_CSD: CSD plotting with Octave migh not give very beautiful results. Ask the Octave maintainers to improve the 3D plotting functionality of Octave.')

% we're running Octave, which does a bad job in plotting waterfalls like CLIO or MLSSA.
    F = union(f,f); % find 'unique' set of all frequency values in the data set
    D = union(d,d); % vector of unique values in d
    Z = repmat(NaN,length(D),length(F));

    for n = 1:length(D);
        i = find(d==D(n));
        Z(n,:) = mataa_interp(f(i),spl(i),F)';
        Z(n, F < min(f(i)) ) = -spl_range;
    end
    
    Z = flipud(Z);
    [X,Y] = meshdom(F,D/10^scale);

    ov = OCTAVE_VERSION;
    i=findstr('.',ov);
        
    if ( str2num(ov(1:i(1)-1)) >= 3 ) % running Octave 3.0.0 or later
        if any(strcmp(options,'contours'))
            meshc(X,Y,Z);
        elseif any(strcmp(options,'contours_only'))
            contour(X,Y,Z);
        elseif any(strcmp(options,'sonogram'))
            contourf(X,Y,Z);
        else
            mesh(X,Y,Z);
        end
            
        view(20,25);
        replot
        r = axis;
        r([1,2]) = [ min(F) , max(F) ];
        r([3,4]) = [ 0 , max(max(Y)) ];
        axis(r);
        
        set(gca,'ydir','reverse');
        set(gca,'xscale','log');
        set(gca,'box','off');
        
        replot
    else % running Octave 2.x or earlier
        error (sprintf('mataa_plot_CSD: You are running Octave %s, but version 3.0 or later is required.',ov));     
    end
else
% We're running Matlab
    D = union(d,d); % vector of unique values in d
    for n = 1:length(D);
    	i = find(d==D(n));
    	xi = f(i);
    	zi = spl(i);
    	
    	if ~isempty(f)
        	% make closed path:
        	xi = [ xi ; xi(end) ; xi(1) ; xi(1) ];
        	zi = [ zi ; -spl_range ; -spl_range ; zi(1) ];
      		yi = repmat(D(n)/10^scale,length(xi),1);
      		poly=fill3(xi,yi,zi,'w');
            set(poly,'EdgeColor',color);
        	hold on
    	end
    end
    hold off
    set(gca,'XScale','log');
	set(gca,'YDir','reverse')
	% grid on
	view(12,30)

	r=axis; r([1 2 5 6]) = [min(f) max(f) max(spl)-spl_range max(spl)];
	axis(r);
	% plot 'frame in the back':
	set(gca,'Box','off'); % should be off anyway, but...
	l=line([r(1) r(2)], [r(3) r(3)], [r(6) r(6)]); set(l,'Color','k');
	l=line([r(1) r(1)], [r(3) r(4)], [r(6) r(6)]); set(l,'Color','k');
	l=line([r(1) r(1)], [r(3) r(4)], [r(5) r(5)]); set(l,'Color','k');
	l=line([r(1) r(1)], [r(3) r(3)], [r(5) r(6)]); set(l,'Color','k');
	l=line([r(2) r(2)], [r(3) r(3)], [r(5) r(6)]); set(l,'Color','k');
end

title(['MATAA: Cumulative spectral decay' annote]);
xlabel('Frequency (Hz)');
switch scale
    case  0
        unit = 's';
    case -3
        unit = 'ms';
    case -6
        unit = 'us';
    case -9
         unit = 'ns';
    otherwise
        unit = sprintf('10^{%i} s',scale);
end
ylabel(['delay (' unit ')']);
zlabel('SPL (dB)');
