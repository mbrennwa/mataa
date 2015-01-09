function mataa_plot_CSD (spl,f,t,spl_range,annote,opts);

% function mataa_plot_CSD (spl,f,t,spl_range,annote,opts);
%
% DESCRIPTION:
% Plot cumulative spectral decay (CSD) data from mataa_IR_to_CSD(...)
% ('waterfall plot'). The argument 'annote' is optional, and can be used to specify annotations to be added to the titles of the plots.
%
% INPUT:
% spl,f,t: see description of output of mataa_IR_to_CSD
% spl_range: the range covered on the y axis of the waterfall diagram (in dB)
% annote: annotations to the plot title (string, optional)
% opts: plot opts (sting or cell string containing multiple opts, optional). Currently, the following opts are available (for Octave 2.9.10 or newer):
%     opts = 'contours' : plot contours of waterfall diagram below the waterfall
%     opts = 'countours2': plot contours (lines) only in a 2-D plot
%     opts = 'shaded2': similar to 'contours2', but fills the areas in between the contours with a solid color)
% 
% EXAMPLE:
% [h,t] = mataa_IR_demo ('FE108');
% T = [0:1E-4:4E-3];
% [spl,f,t] = mataa_IR_to_CSD (h,t,T,1/24);
% mataa_plot_CSD (spl,f,t,50);
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

if ~exist('annote')
    annote = '';
end

if ~exist('opts')
    opts = '';
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
t = t(:);

scale = 0;
while scale > ceil(log10(max(t)))
	scale = scale-3;
end

spl = spl-max(spl);
spl(find(spl < -spl_range)) = -spl_range;

if exist('OCTAVE_VERSION')

% warning('mataa_plot_CSD: CSD plotting with Octave migh not give very beautiful results. Ask the Octave maintainers to improve the 3D plotting functionality of Octave.')

% we're running Octave, which does a bad job in plotting waterfalls like CLIO or MLSSA.
    F = union(f,f); % find 'unique' set of all frequency values in the data set
    T = union(t,t); % vector of unique values in t
    Z = repmat(NaN,length(T),length(F));

    for n = 1:length(T);
        i = find(t==T(n));
        Z(n,:) = mataa_interp(f(i),spl(i),F)';
        Z(n, F < min(f(i)) ) = -spl_range;
    end
    
    [X,Y] = meshgrid(F,T/10^scale);

    ov = OCTAVE_VERSION;
    i=findstr('.',ov);
        
    if ( str2num(ov(1:i(1)-1)) >= 3 ) % running Octave 3.0.0 or later
        if any(strcmp(opts,'contours'))
            meshc(X,Y,Z);
        elseif any(strcmp(opts,'contours2'))
            contour(X,Y,Z);
        elseif any(strcmp(opts,'shaded2'))
            contourf(X,Y,Z);
        else
            mesh(X,Y,Z);
        end
            
        view(20,25);
        
        r = axis;
        r([1,2]) = [ min(F) , max(F) ];
        r([3,4]) = [ 0 , max(max(Y)) ];
        axis(r);
        
        set(gca,'ydir','reverse');
        set(gca,'xscale','log');
        set(gca,'box','off');
        
    else % running Octave 2.x or earlier
        error (sprintf('mataa_plot_CSD: You are running Octave %s, but version 3.0 or later is required.',ov));     
    end
else
% We're running Matlab
    T = union(t,t); % vector of unique values in t
    for n = 1:length(T);
    	i = find(t==T(n));
    	xi = f(i);
    	zi = spl(i);
    	
    	if ~isempty(f)
        	% make closed path:
        	xi = [ xi ; xi(end) ; xi(1) ; xi(1) ];
        	zi = [ zi ; -spl_range ; -spl_range ; zi(1) ];
      		yi = repmat(T(n)/10^scale,length(xi),1);
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
