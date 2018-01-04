function [h,t,unit] = mataa_IR_demo (IRtype)

% function [h,t,unit] = mataa_IR_demo (IRtype)
% 
% DESCRIPTION:
% This function returns the an impulse response h(t), specified by 'IRtype'.
% 
% INPUT:
% type (optional): string describing the type of impulse response (see below). If not specified, type = 'DEFAULT' is used.
% 
% valid choices for 'IRtype':
% 
% FE108: impulse response of a Fostex FE108Sigma full-range driver, sampled at a rate of 96 kHz.
% 
% DIRAC: dirac impulse (first sample is 1, all others are zero), with a length of 1 second, sampled at 44.1 kHz.
% 
% EXP: exponential decay ( f(t) = exp(-t/tau), with tau=1E-2 seconds), with a length of 1 second, sampled at 44.1 kHz.
% 
% DEFAULT: same as 'FE108'.
%  
% OUTPUT:
% h: impulse response samples
% t: time coordinates of samples
% unit: unit of data in h
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

if ~exist('IRtype','var')
    IRtype = 'default';
end

IRtype = upper(IRtype);

if strcmp(IRtype,'DEFAULT')
    IRtype = 'FE108';
end

switch IRtype
    case 'DIRAC'
        t = [0:44100-1]/44100;
        h = repmat(0,1,44100);
        h(1)=1;
	unit = 'FS'; % digital Full Scale
    case 'EXP'
        t = [0:44100-1]/44100;
        h = exp(-t/1E-2);
	unit = 'FS'; % digital Full Scale
    case 'FE108'
        h = [
         0
         0
         0
         0
         0
         0
         0
         0
         0
         0
         0
         0
         0
         0
         0
         0
         0
         0
         0
         0
         0
         0
         0
         0
         0
         0
         0
         0
         -0.000103120438082899
         -2.9375767681995e-05
         7.42007445959325e-05
         0.00018685385891295
         0.000249473169065933
         0.000257551579155072
         0.000223124506788398
         0.000218804116299831
         0.000236675725611922
         0.000289975233951599
         0.000715349433664814
         0.00287822134275638
         0.0111233524162972
         0.0331963848440759
         0.0632995041662215
         0.077082050288352
         0.0596463831712259
         0.0191308200894956
         -0.0213801426482172
         -0.0415316102372404
         -0.0366289700398654
         -0.01755386569572
         0.000208326435510007
         0.0051337787066307
         -0.00442071603274413
         -0.020440189063412
         -0.0338805459913122
         -0.039151534460442
         -0.0342061630924356
         -0.0216826832254204
         -0.00998026786401587
         -0.00304491948575804
         -0.00128183884119409
         -0.00686604989194886
         -0.0157843918801028
         -0.0209362957207375
         -0.0194021268592588
         -0.011440256941009
         -0.00190666941253948
         0.0030909045378638
         0.00327198488795641
         0.00139182306735325
         -0.000843596626495257
         -0.0018229747511068
         -0.000749936291506454
         0.00128370931869292
         0.0033093175514511
         0.0053419280172597
         0.00636476610664939
         0.00601695202589932
         0.00431184412787548
         0.00100053660282209
         -0.00163144082269745
         -0.00112659479580452
         0.00339932333909575
         0.011179803795466
         0.0177001407927418
         0.0184008088080785
         0.0130214336455312
         0.00426252462292096
         -0.00335401333157789
         -0.00660092143629088
         -0.00558002944678238
         -0.00186494571574965
         0.00230034954410559
         0.00434172759165328
         0.00342144465078584
         0.000892810107568494
         -0.00171049223350515
         -0.00277870469996549
         -0.00119886065732574
         0.00206195524709944
         0.00491180261939966
         0.00542570628429839
         0.00301298374805747
         -0.000925772829565892
         -0.00467262706768417
         -0.00710832102790296
         -0.00790770980239916
         -0.00765125192827236
         -0.00645430494573834
         -0.00376481857605337
         0.000313379257564735
         0.00380784166296309
         0.00396042329256032
         0.000541421975606115
         -0.00394958160319357
         -0.00673265410699946
         -0.00667423893114368
         -0.00433522005448306
         -0.00119319071484579
         0.00126914063058279
         0.00214392841507259
         0.001310633212953
         -0.000643064697195812
         -0.00269152641817665
         -0.00359111497077613
         -0.00256024149117342
         -0.000154392016832837
         0.00219441813161188
         0.00370064544120614
         0.00376843649671473
         0.00231401054997005
         0.000375884028628451
         -0.00100788822834165
         -0.00114336718887746
         -2.74843729975092e-05
         0.00149544403927036
         0.00274487158112388
         0.00378650215165399
         0.00484404414392548
         0.00576304168757913
         0.00598815708282468
         0.00515012651595888
         0.00342024119643053
         0.00133133969695239
         -0.000481079535635299
         -0.00145654427366707
         -0.0014087024096642
         -0.000803292836887416
         -0.000280639705185804
         -0.00022343447648458
         -0.000566704355171279
         -0.000849953718644434
         -0.000803193414844302
         -0.00051100602674673
         2.05284319545134e-05
         0.00105901315996313
         0.00269461411788127
         0.00425515409487511
         0.00455864751000284
         0.00300811408948885
         0.000357188616018967
         -0.00183875356619254
         -0.00250143789235401
         -0.00163615963170391
         -0.000162467882351665
         0.000832450651981262
         0.000995026460559094
         0.000500059078268132
         -0.000332052563564389
         -0.00113371113140101
         -0.00160287596753809
         -0.00158397152902381
         -0.00119570942039975
         -0.000746293653348267
         -0.000415816302906679
         -0.000264386847623097
         -0.000237966689515635
         -0.000163524969771308
         1.42179499818708e-05
         0.000364747404110703
         0.000730669259998036
         0.000780678655477049
         0.000383603858915292
         -0.000218773750663179
         -0.000656793052723244
         -0.000728158583765841
         -0.000652231891570749
         -0.000809046587645614
         -0.00129159175326708
         -0.00187390704255171
         -0.00223555116358563
         -0.00219768648632342
         -0.00183316532431964
         -0.00128156510054079
         -0.000632895965054791
         -7.86172799970306e-05
         0.000327680886524345
         0.000636033162977694
         0.000944517697526713
         0.0013030131876479
         0.00154647182742593
         0.00153392307083108
         0.0013625353475278
         0.00116349490134637
         0.0010693827341233
         0.00104653128769356
         0.000954360334481192
         0.000787745610734202
         0.000615137676621682
         0.000481364893864195
         0.000320362293931539
         4.09723046466739e-05
         -0.000322108432599757
         -0.000526736658124939
         -0.000376368977064146
         4.05682563076885e-05
         0.00040506562497389
         0.000416134462170367
         5.18771483909358e-05
         -0.000427757124833518
         -0.000796974956382693
         -0.000802532936801515
         -0.000416241533346144
         -2.5984651636617e-05
         5.0380493163514e-05
         -0.000155904420409652
         -0.000460030524497999
         -0.000645259381193108
         -0.000646727313939213
         -0.000589365731112077
         -0.000560480342365581
         -0.000583527195779147
         -0.000545348323715856
         -0.00040811689478195
         -0.000343227855025435
         -0.000385435247581757
         -0.000516126181798438
         -0.000697524985292305
         -0.000840339345948797
         -0.000929752950856704
         -0.000827568938617067
         -0.000488361483633328
         -0.000166033456029241
         -7.14030038830552e-05
         -0.000164974544447154
         -0.00035002940258763
         -0.000492225028198436
         -0.000488659431413125
         -0.000324041698713558
         -4.95203637029201e-05
         0.000254161732356636
         0.000564622988138045
         0.000830032959793635
         0.000962753312264633
         0.000938405251107526
         0.000787950181355243
         0.000510603591548602
         0.000207771386840847
         3.18472397099736e-05
         5.43699475385972e-05
         0.000227925831548926
         0.000419000329878109
         0.000467121853066969
         0.000426206465969095
         0.000359476002303759
         0.000261944594981428
         0.000155224789078702
         0.000121106437722627
         0.000211305546638443
         0.000394366154895608
         0.000615444994700807
         0.000698199101533468
         0.000518301112437293
         0.000164852363832898
         -0.000166480681707537
         -0.000319822399112429
         -0.000197110658069567
         7.51058972559708e-05
         0.000285061556090996
         0.000260364592066636
         2.54972429226054e-05
         -0.000296096961033462
         -0.000523995519398378
         -0.000564751292052208
         -0.000509467380597247
         -0.000469269829183248
         -0.000469279202953413
         -0.000472025716477272
         -0.000441257438245821
         -0.000362884088456549
         -0.000317187620769453
         -0.000260231985393747
         -0.000161166981844855
         -5.11313092775802e-05
         7.47396663954665e-06
         5.90980301046358e-06
         -9.845860187838e-05
         -0.000261515825458985
         -0.000397249670088497
         -0.000472589631511008
         -0.000481549105545184
         -0.000439058712113622
         -0.000361630444269285
         -0.000281640663080743
         -0.000177529778684607
         -2.47629393335274e-06
         0.000247088041213919
         0.00047385434927974
         0.000604596394611732
         0.000639679007222208
         0.000636272326655017
         0.000633851969614912
         0.000642568510610134
         0.000666667024908676
         0.000673227830589461
         0.000648147573417405
         0.000589658042395701
        ];
        
        % h = h/max(abs(h));
        
        t = [0:1/96000:(length(h)-1)/96000]';
        
	unit = 'FS'; % digital Full Scale

    otherwise
        error(sprintf('mataa_IR_demo: unknown type %s.',IRtype))

end

% make sure h and t are column vectors:
h = h(:);
t = t(:);

