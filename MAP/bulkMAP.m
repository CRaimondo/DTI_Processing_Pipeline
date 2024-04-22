

%this script is set up to work from one folder containing pt folders
%pt folders each contain a dti_outputs folder, script iterates through each
%pt's dti_outputs and runs MAP processing on each one

%IMPORTANT:
%make sure the b0 file is in .nii format otherwise mrconvert it
%make sure bvec and bval files are also in dti_outputs folder
%scroll to bottom of this script and specify original folder
%specify how many pt folders there are immediately below
for i = 1:8
        
    
    
    currentDir = pwd;

    dirContents = dir(currentDir);

    folders = {dirContents([dirContents.isdir]).name};

    folders = folders(~ismember(folders, {'.', '..'}));
    cd(folders{i})
    cd dti_outputs
 clc   
clear all
setup__DMRIMatlab_toolbox('useparallel',true);
b01=MRIread('b0.nii');
b011=b01.vol;
mask0=MRIread('mask.nii');
mask1=mask0.vol;
[r c z]=size(mask1);
for i=1:z
    mask(:,:,i)=im2bw(mask1(:,:,i));
end
bi0=load ('bval.bval');
bi1=bi0';

pg0=load ('bvec.bvec');
pg1=pg0';
dti0=MRIread('dti_denoise_preproc_unbiased.nii');
dwi=dti0.vol;
[atti,gi,bi]=dwi2atti(dwi,pg1,bi1);


mu = 0.00015; % Changing the value will trigger the entire demo
tic;
tic;
[lpar,lperp,f] = atti2micro( atti, gi, bi, 'tl', 1.0e-6, 'tu', 1-1.0e-6, ...
    'ADC0', 3.0e-3, 'usef', false, 'mask', mask, 'bth', 100, 'mlperp',0.01e-3, ...
    'mu', 5.0e-4, 'verbose', true ); % No longer use the 'usef' flag




b01.vol=lperp;
MRIwrite(b01, 'lperp.nii')

b01.vol=lpar;
MRIwrite(b01, 'lpar.nii')

b01.vol=f;
MRIwrite(b01, 'f.nii')


%ODF Estimation%

tic; %
sh = micro2shodf( atti, gi, bi, lpar, lperp, [], 'L', 8, 'tl', 1.0e-6, 'tu', ...
    1-1.0e-6, 'mask', mask,'optimal', true, 'lambda', 0.0005 ); % The 'optimal' flag means one matrix is inverted at each voxel
T = toc;
fprintf(1,'It took %f seconds to compute the ODFs\n',T);

close(figure(1)); close(figure(2)); % Close previous figures if necessary
hf = figure(1); ha = axes('Parent',hf);
sl = 14; mx = 53; % Select the piece of data to plot with our cool plotdmri3d
plotdmri3d(sh,[1,mx],[1,110],[sl,sl],'bgimage', 'color', 'bgsh', sh, 'ha', ...
    ha, 'bgalpha', 1, 'mask', mask, 'bbox', true, 'glyphs', false, 'origin', ...
    [0;0;0],'direction',eye(3),'space','LPS','mframe',eye(3) ); % color-by-orientation half the slice
plotdmri3d(sh,[mx,101],[1,110],[sl,sl],'bgimage', 'fa', 'bgsh', sh, 'ha', ...
    ha,'bgalpha', 0.9, 'mask', mask, 'bbox', false, 'glyphs', false, 'origin', ...
    [0;0;0],'direction',eye(3),'space','LPS','mframe',eye(3)  ); % FA image for the other half of the slice
plotdmri3d(sh,[mx+2,mx+8],[45,65],[sl,sl],'ha',ha, 'bgimage', 'fa', 'bgsh', ...
    sh, 'bgalpha', 0, 'mask', mask, 'bbox', false, 'glyphs', true, 'angleres', ...
    642, 'glyphspc', [1;1;1], 'glyphsc', 2,'glyphscvar', 'none', 'origin', ...
    [0;0;0],'direction',eye(3),'space','LPS','mframe',eye(3)  ); % Cool ODF glyphs in the CC and CG
light; % Even cooler look
axis('equal');
rotate3d('on');
title('Drag to rotare 3-D');




%Characterization of diffusion via moments computation. Full moments%

tic;
UEm2 = micro2moments( [], lpar, lperp, [], 'mask', mask, 'type', 'Ef', 'nu', -2 ); % Orders >-3 are allowed
T = toc; % For integer nu, the computation is quite fast
fprintf(1,'It took %f seconds to compute the moment\n',T);

UEm1 = micro2moments( [], lpar, lperp, [], 'mask', mask, 'type', 'Ef', 'nu', -1, 'clean', 100 );  % Potentiate small q
UEp0 = micro2moments( [], lpar, lperp, [], 'mask', mask, 'type', 'Ef', 'nu', 0,  'clean', 100 );  % This is just RTOP
UEp1 = micro2moments( [], lpar, lperp, [], 'mask', mask, 'type', 'Ef', 'nu', 1,  'clean', 100 );  % Potentiate far-from-zero q
UEp2 = micro2moments( [], lpar, lperp, [], 'mask', mask, 'type', 'Ef', 'nu', 2,  'clean', 100 );  % This is just QMSD

b01.vol=UEm2;
MRIwrite(b01, 'UEm2.nii')

b01.vol=UEm1;
MRIwrite(b01, 'UEm1.nii')

b01.vol=UEp0;
MRIwrite(b01, 'RTOP.nii')

b01.vol=UEp1;
MRIwrite(b01, 'UEp1.nii')

b01.vol=UEp2;
MRIwrite(b01, 'QMSD.nii')


MAP = psychedelia(512);
sl = [4,8,12]; % Slices to plot
close(figure(1)); close(figure(2)); % Close previous figures if needed
hf = figure(1);
set(hf,'Name','Full moments over E(q)','Position',[10,10,900,460]);
R=1; C=5;
r=1; c=1; subplot('Position',[(c-1)/C,(r-1)/R,1/C,1/R]);
imagesc([UEm2(:,:,sl(1))';UEm2(:,:,sl(2))';UEm2(:,:, ...
    sl(3))';]); colormap(MAP); colorbar; title('\Upsilon^{-2}');
axis('equal');axis('off');axis('tight');
r=1; c=2; subplot('Position',[(c-1)/C,(r-1)/R,1/C,1/R]);
imagesc([UEm1(:,:,sl(1))';UEm1(:,:,sl(2))';UEm1(:,:, ...
    sl(3))';]); colormap(MAP); colorbar; title('\Upsilon^{-1}');
axis('equal');axis('off');axis('tight');
r=1; c=3; subplot('Position',[(c-1)/C,(r-1)/R,1/C,1/R]);
imagesc([UEp0(:,:,sl(1))';UEp0(:,:,sl(2))';UEp0(:,:, ...
    sl(3))';]); colormap(MAP); colorbar; title('\Upsilon^{0} = RTOP');
axis('equal');axis('off');axis('tight');
r=1; c=4; subplot('Position',[(c-1)/C,(r-1)/R,1/C,1/R]);
imagesc([UEp1(:,:,sl(1))';UEp1(:,:,sl(2))';UEp1(:,:, ...
    sl(3))';]); colormap(MAP); colorbar; title('\Upsilon^{1}');
axis('equal');axis('off');axis('tight');
r=1; c=5; subplot('Position',[(c-1)/C,(r-1)/R,1/C,1/R]);
imagesc([UEp2(:,:,sl(1))';UEp2(:,:,sl(2))';UEp2(:,:, ...
    sl(3))';]); colormap(MAP); colorbar; title('\Upsilon^{2} = QMSD');
axis('equal');axis('off');axis('tight');


UPm2 = micro2moments( [], lpar, lperp, [], 'mask', mask, 'type', 'Pf', 'nu', -2 ); % Orders >-3 are allowed
UPm1 = micro2moments( [], lpar, lperp, [], 'mask', mask, 'type', 'Pf', 'nu', -1 ); % Potentiate small R
UPp0 = micro2moments( [], lpar, lperp, [], 'mask', mask, 'type', 'Pf', 'nu', 0 );  % This is just 1!!!
UPp1 = micro2moments( [], lpar, lperp, [], 'mask', mask, 'type', 'Pf', 'nu', 1 );  % Potentiate far-from-zero R
UPp2 = micro2moments( [], lpar, lperp, [], 'mask', mask, 'type', 'Pf', 'nu', 2 );  % This is just MSD
sl = [4,8,12]; % Slices to plot
hf = figure(2);
set(hf,'Name','Full moments over P(R)','Position',[10,10,900,460]);
R=1; C=5;
r=1; c=1; subplot('Position',[(c-1)/C,(r-1)/R,1/C,1/R]);
imagesc([UPm2(:,:,sl(1))';UPm2(:,:,sl(2))';UPm2(:,:, ...
    sl(3))';]); colormap(MAP); colorbar; title('\upsilon^{-2}');
axis('equal');axis('off');axis('tight');
r=1; c=2; subplot('Position',[(c-1)/C,(r-1)/R,1/C,1/R]);
imagesc([UPm1(:,:,sl(1))';UPm1(:,:,sl(2))';UPm1(:,:, ...
    sl(3))';]); colormap(MAP); colorbar; title('\upsilon^{-1}');
axis('equal');axis('off');axis('tight');
r=1; c=3; subplot('Position',[(c-1)/C,(r-1)/R,1/C,1/R]);
imagesc([UPp0(:,:,sl(1))';UPp0(:,:,sl(2))';UPp0(:,:, ...
    sl(3))';]); colormap(MAP); colorbar; title('\upsilon^{0} = 1');
axis('equal');axis('off');axis('tight');
r=1; c=4; subplot('Position',[(c-1)/C,(r-1)/R,1/C,1/R]);
imagesc([UPp1(:,:,sl(1))';UPp1(:,:,sl(2))';UPp1(:,:, ...
    sl(3))';]); colormap(MAP); colorbar; title('\upsilon^{1}');
axis('equal');axis('off');axis('tight');
r=1; c=5; subplot('Position',[(c-1)/C,(r-1)/R,1/C,1/R]);
imagesc([UPp2(:,:,sl(1))';UPp2(:,:,sl(2))';UPp2(:,:, ...
    sl(3))';]); colormap(MAP); colorbar; title('\upsilon^{2} = MSD');
axis('equal');axis('off');axis('tight');

b01.vol=UPm2;
MRIwrite(b01, 'UPm2.nii')

b01.vol=UPm1;
MRIwrite(b01, 'UPm1.nii')

b01.vol=UPp0;
MRIwrite(b01, 'UPp0.nii')

b01.vol=UPp1;
MRIwrite(b01, 'UPp1.nii')

b01.vol=UPp2;
MRIwrite(b01, 'MSD.nii')



%Axial moments%

tens = shadc2dti(sh,'mask',mask,'unroll',false ); % Compute a tensor field from the SH volume
u0 = dti2xyz( tens, 'mask', mask ); % Maximum diffusion direction

tic; % Non-integer moments take far longer to compute because of the usage of hypergeom
UEm12 = micro2moments( sh, lpar, lperp, [], 'mask', mask, 'type', 'Ea', 'nu', -1/2, 'u0', u0 ); % Orders >-1 are allowed
T = toc;
fprintf(1,'It took %f seconds to compute the moment\n',T);

b01.vol=UEm12;
MRIwrite(b01, 'UEm12.nii')

UEm14 = micro2moments( sh, lpar, lperp, [], 'mask', mask, 'type', 'Ea', 'nu', -1/4, 'u0', u0, 'clean', 100 ); % Potentiate small q
UEp0  = micro2moments( sh, lpar, lperp, [], 'mask', mask, 'type', 'Ea', 'nu', 0, 'u0', u0,    'clean', 100 ); % This is just RTPP
UEp1  = micro2moments( sh, lpar, lperp, [], 'mask', mask, 'type', 'Ea', 'nu', 1, 'u0', u0,    'clean', 100 ); % Potentiate far-from-zero q
UEp2  = micro2moments( sh, lpar, lperp, [], 'mask', mask, 'type', 'Ea', 'nu', 2, 'u0', u0,    'clean', 100 ); % Potentiate farther-from-zero q

b01.vol=UEm14;
MRIwrite(b01, 'UEm14.nii')

b01.vol=UEp0;
MRIwrite(b01, 'RTPP.nii')

b01.vol=UEp1;
MRIwrite(b01, 'UEp1.nii')

b01.vol=UEp2;
MRIwrite(b01, 'UEp.nii')

sl = [4,8,12]; % Slices to plot
close(figure(1)); close(figure(2)); % Close previous figures if needed
hf = figure(1);
set(hf,'Name','Axial moments over E(q)','Position',[10,10,900,460]);
R=1; C=5;
r=1; c=1; subplot('Position',[(c-1)/C,(r-1)/R,1/C,1/R]);
imagesc([UEm12(:,:,sl(1))';UEm12(:,:,sl(2))';UEm12(:,:, ...
    sl(3))';]); colormap(MAP); colorbar; title('\Upsilon_a^{-1/2}');
axis('equal');axis('off');axis('tight');
r=1; c=2; subplot('Position',[(c-1)/C,(r-1)/R,1/C,1/R]);
imagesc([UEm14(:,:,sl(1))';UEm14(:,:,sl(2))';UEm14(:,:, ...
    sl(3))';]); colormap(MAP); colorbar; title('\Upsilon_a^{-1/4}');
axis('equal');axis('off');axis('tight');
r=1; c=3; subplot('Position',[(c-1)/C,(r-1)/R,1/C,1/R]);
imagesc([UEp0(:,:,sl(1))';UEp0(:,:,sl(2))';UEp0(:,:, ...
    sl(3))';]); colormap(MAP); colorbar; title('\Upsilon_a^{0} = \upsilon_p^{0}=RTPP');
axis('equal');axis('off');axis('tight');
r=1; c=4; subplot('Position',[(c-1)/C,(r-1)/R,1/C,1/R]);
imagesc([UEp1(:,:,sl(1))';UEp1(:,:,sl(2))';UEp1(:,:, ...
    sl(3))';]); colormap(MAP); colorbar; title('\Upsilon_a^{1}');
axis('equal');axis('off');axis('tight');
r=1; c=5; subplot('Position',[(c-1)/C,(r-1)/R,1/C,1/R]);
imagesc([UEp2(:,:,sl(1))';UEp2(:,:,sl(2))';UEp2(:,:, ...
    sl(3))';]); colormap(MAP); colorbar; title('\Upsilon_a^{2}');
axis('equal');axis('off');axis('tight');

UPm12 = micro2moments( sh, lpar, lperp, [], 'mask', mask, 'type', 'Pa', 'nu', -1/2, 'u0', u0, 'clean',  100 ); % Orders >-1 are allowed
UPm14 = micro2moments( sh, lpar, lperp, [], 'mask', mask, 'type', 'Pa', 'nu', -1/4, 'u0', u0, 'clean',  100 ); % Potentiate small q
UPp0  = micro2moments( sh, lpar, lperp, [], 'mask', mask, 'type', 'Pa', 'nu', 0, 'u0', u0,    'clean',  100 );
UPp1  = micro2moments( sh, lpar, lperp, [], 'mask', mask, 'type', 'Pa', 'nu', 1, 'u0', u0,    'clean',  100 ); % Potentiate far-from-zero q
UPp2  = micro2moments( sh, lpar, lperp, [], 'mask', mask, 'type', 'Pa', 'nu', 2, 'u0', u0,    'clean',  100 ); % Potentiate farther-from-zero q
sl = [4,8,12]; % Slices to plot
hf = figure(2);
set(hf,'Name','Axial moments over P(R)','Position',[10,10,900,460]);
R=1; C=5;
r=1; c=1; subplot('Position',[(c-1)/C,(r-1)/R,1/C,1/R]);
imagesc([UPm12(:,:,sl(1))';UPm12(:,:,sl(2))';UPm12(:,:, ...
    sl(3))';]); colormap(MAP); colorbar; title('\upsilon_a^{-1/2}');
axis('equal');axis('off');axis('tight');
r=1; c=2; subplot('Position',[(c-1)/C,(r-1)/R,1/C,1/R]);
imagesc([UPm14(:,:,sl(1))';UPm14(:,:,sl(2))';UPm14(:,:, ...
    sl(3))';]); colormap(MAP); colorbar; title('\upsilon_a^{-1/4}');
axis('equal');axis('off');axis('tight');
r=1; c=3; subplot('Position',[(c-1)/C,(r-1)/R,1/C,1/R]);
imagesc([UPp0(:,:,sl(1))';UPp0(:,:,sl(2))';UPp0(:,:, ...
    sl(3))';]); colormap(MAP); colorbar; title('\upsilon_a^{0} = \Upsilon_p^{0} = RTAP');
axis('equal');axis('off');axis('tight');
r=1; c=4; subplot('Position',[(c-1)/C,(r-1)/R,1/C,1/R]);
imagesc([UPp1(:,:,sl(1))';UPp1(:,:,sl(2))';UPp1(:,:, ...
    sl(3))';]); colormap(MAP); colorbar; title('\upsilon_a^{1}');
axis('equal');axis('off');axis('tight');
r=1; c=5; subplot('Position',[(c-1)/C,(r-1)/R,1/C,1/R]);
imagesc([UPp2(:,:,sl(1))';UPp2(:,:,sl(2))';UPp2(:,:, ...
    sl(3))';]); colormap(MAP); colorbar; title('\upsilon_a^{2}');
axis('equal');axis('off');axis('tight');

b01.vol=UPm12;
MRIwrite(b01, 'UPm12.nii')

b01.vol=UPm14;
MRIwrite(b01, 'UPm14.nii')

b01.vol=UPp0;
MRIwrite(b01, 'UPp0.nii')

b01.vol=UPp1;
MRIwrite(b01, 'UPp1.nii')

b01.vol=UPp2;
MRIwrite(b01, 'UPp2.nii')



%Planar moments%

UEm12 = micro2moments( sh, lpar, lperp, [], 'mask', mask, 'type', 'Ep', 'nu', -1/2, 'u0', u0, 'clean',  100 ); % Orders >-2 are allowed
UEm14 = micro2moments( sh, lpar, lperp, [], 'mask', mask, 'type', 'Ep', 'nu', -1/4, 'u0', u0, 'clean',  100 ); % Potentiate small q
UEp0  = micro2moments( sh, lpar, lperp, [], 'mask', mask, 'type', 'Ep', 'nu', 0, 'u0', u0,    'clean',  100 ); % This is just RTAP
UEp1  = micro2moments( sh, lpar, lperp, [], 'mask', mask, 'type', 'Ep', 'nu', 1, 'u0', u0,    'clean',  100 ); % Potentiate far-from-zero q
UEp2  = micro2moments( sh, lpar, lperp, [], 'mask', mask, 'type', 'Ep', 'nu', 2, 'u0', u0,    'clean',  100 ); % Potentiate farther-from-zero q
sl = [4,8,12]; % Slices to plot
close(figure(1)); close(figure(2));
hf = figure(1);
set(hf,'Name','Planar moments over E(q)','Position',[10,10,900,460]);
R=1; C=5;
r=1; c=1; subplot('Position',[(c-1)/C,(r-1)/R,1/C,1/R]);
imagesc([UEm12(:,:,sl(1))';UEm12(:,:,sl(2))';UEm12(:,:, ...
    sl(3))';]); colormap(MAP); colorbar; title('\Upsilon_p^{-1/2}');
axis('equal');axis('off');axis('tight');
r=1; c=2; subplot('Position',[(c-1)/C,(r-1)/R,1/C,1/R]);
imagesc([UEm14(:,:,sl(1))';UEm14(:,:,sl(2))';UEm14(:,:, ...
    sl(3))';]); colormap(MAP); colorbar; title('\Upsilon_p^{-1/4}');
axis('equal');axis('off');axis('tight');
r=1; c=3; subplot('Position',[(c-1)/C,(r-1)/R,1/C,1/R]);
imagesc([UEp0(:,:,sl(1))';UEp0(:,:,sl(2))';UEp0(:,:, ...
    sl(3))';]); colormap(MAP); colorbar; title('\Upsilon_p^{0} = \upsilon_a^{0}=RTAP');
axis('equal');axis('off');axis('tight');
r=1; c=4; subplot('Position',[(c-1)/C,(r-1)/R,1/C,1/R]);
imagesc([UEp1(:,:,sl(1))';UEp1(:,:,sl(2))';UEp1(:,:, ...
    sl(3))';]); colormap(MAP); colorbar; title('\Upsilon_p^{1}');
axis('equal');axis('off');axis('tight');
r=1; c=5; subplot('Position',[(c-1)/C,(r-1)/R,1/C,1/R]);
imagesc([UEp2(:,:,sl(1))';UEp2(:,:,sl(2))';UEp2(:,:, ...
    sl(3))';]); colormap(MAP); colorbar; title('\Upsilon_p^{2}');
axis('equal');axis('off');axis('tight');

b01.vol=UEm12;
MRIwrite(b01, 'UEm12.nii')

b01.vol=UPm14;
MRIwrite(b01, 'UPm14.nii')

b01.vol=UEp0;
MRIwrite(b01, 'RTAP.nii')

b01.vol=UEp1;
MRIwrite(b01, 'UEp1.nii')

b01.vol=UEp2;
MRIwrite(b01, 'UEp2.nii')

UPm12 = micro2moments( sh, lpar, lperp, [], 'mask', mask, 'type', 'Pp', 'nu', -1/2, 'u0', u0, 'clean',  100 ); % Orders >-2 are allowed
UPm14 = micro2moments( sh, lpar, lperp, [], 'mask', mask, 'type', 'Pp', 'nu', -1/4, 'u0', u0, 'clean',  100 ); % Potentiate small q
UPp0  = micro2moments( sh, lpar, lperp, [], 'mask', mask, 'type', 'Pp', 'nu', 0, 'u0', u0,    'clean',  100 );
UPp1  = micro2moments( sh, lpar, lperp, [], 'mask', mask, 'type', 'Pp', 'nu', 1, 'u0', u0,    'clean',  100 ); % Potentiate far-from-zero q
UPp2  = micro2moments( sh, lpar, lperp, [], 'mask', mask, 'type', 'Pp', 'nu', 2, 'u0', u0,    'clean',  100 ); % Potentiate farther-from-zero q
sl = [4,8,12]; % Slices to plot
hf = figure(2);
set(hf,'Name','Planar moments over P(R)','Position',[10,10,900,460]);
R=1; C=5;
r=1; c=1; subplot('Position',[(c-1)/C,(r-1)/R,1/C,1/R]);
imagesc([UPm12(:,:,sl(1))';UPm12(:,:,sl(2))';UPm12(:,:, ...
    sl(3))';]); colormap(MAP); colorbar; title('\upsilon_p^{-1/2}');
axis('equal');axis('off');axis('tight');
r=1; c=2; subplot('Position',[(c-1)/C,(r-1)/R,1/C,1/R]);
imagesc([UPm14(:,:,sl(1))';UPm14(:,:,sl(2))';UPm14(:,:, ...
    sl(3))';]); colormap(MAP); colorbar; title('\upsilon_p^{-1/4}');
axis('equal');axis('off');axis('tight');
r=1; c=3; subplot('Position',[(c-1)/C,(r-1)/R,1/C,1/R]);
imagesc([UPp0(:,:,sl(1))';UPp0(:,:,sl(2))';UPp0(:,:, ...
    sl(3))';]); colormap(MAP); colorbar; title('\upsilon_p^{0} = \Upsilon_a^{0} = RTPP');
axis('equal');axis('off');axis('tight');
r=1; c=4; subplot('Position',[(c-1)/C,(r-1)/R,1/C,1/R]);
imagesc([UPp1(:,:,sl(1))';UPp1(:,:,sl(2))';UPp1(:,:, ...
    sl(3))';]); colormap(MAP); colorbar; title('\upsilon_p^{1}');
axis('equal');axis('off');axis('tight');
r=1; c=5; subplot('Position',[(c-1)/C,(r-1)/R,1/C,1/R]);
imagesc([UPp2(:,:,sl(1))';UPp2(:,:,sl(2))';UPp2(:,:, ...
    sl(3))';]); colormap(MAP); colorbar; title('\upsilon_p^{2}');
axis('equal');axis('off');axis('tight');

%Propagator Anisotropy%

tic;
pa = micro2pa( sh, lpar, lperp, 'mask', mask, 'epsilon', [] );
T = toc; % This is pretty fast
fprintf(1,'It took %f seconds to compute the PA\n',T);

close(figure(1));
figure(1);
sl = [5,7,9,11,13,15]; % These are the slices we will show
PA = [ pa(:,:,sl(1))',pa(:,:,sl(2))';pa(:,:,sl(3))',pa(:,:,sl(4))';pa(:,:, ...
    sl(5))',pa(:,:,sl(6))'];
imagesc(PA,[0,1]); colormap(MAP); colorbar; title('Propagator anisotropy');
axis('equal');axis('off');axis('tight');
b01.vol=pa;
MRIwrite(b01, 'PA.nii')
pa = micro2pa( sh, lpar, lperp, 'mask', mask, 'epsilon', 0.4 );
figure(1);
sl = [5,7,9,11,13,15]; % These are the slices we will show
PA = [ pa(:,:,sl(1))',pa(:,:,sl(2))';pa(:,:,sl(3))',pa(:,:,sl(4))';pa(:,:, ...
    sl(5))',pa(:,:,sl(6))'];
imagesc(PA,[0,1]); colormap(MAP); colorbar; title('Propagator anisotropy (gamma corrected)');
axis('equal');axis('off');axis('tight');
b01.vol=pa;
MRIwrite(b01, 'PA_GC.nii')
pa = micro2pa( [], lpar, lperp, 'mask', mask, 'epsilon', [], 'micro', true );
figure(1);
sl = [5,7,9,11,13,15]; % These are the slices we will show
PA = [ pa(:,:,sl(1))',pa(:,:,sl(2))';pa(:,:,sl(3))',pa(:,:,sl(4))';pa(:,:, ...
    sl(5))',pa(:,:,sl(6))'];
imagesc(PA,[0,1]); colormap(MAP); colorbar; title('micro-Propagator anisotropy');
axis('equal');axis('off');axis('tight');

b01.vol=pa;
MRIwrite(b01, 'mPA.nii')

%Non-gaussianity%

tic;
atti2 = micro2atti(sh, lpar, lperp, [], gi(bi<=1999,:), bi(bi<=1999,:), 'mask', mask );
T = toc;
fprintf(1,'It took %f seconds to reconstruct E(q) from the model\n',T);

tic;
sh2 = atti2shadc( atti2, gi(bi<=1999,:), bi(bi<=1999,:), 'mask', mask, 'L', 2 , 'lambda', 0.0001 );
dti = shadc2dti(sh2, 'mask', mask ,'unroll', false);
T = toc;
fprintf(1,'It took %f seconds to compute the tensor model\n',T);

tic;
ng = micro2ng( sh, lpar, lperp, dti, 'mask', mask, 'epsilon',[], 'lambda', 1.0e-9 );
T = toc;
fprintf(1,'It took %f seconds to compute the NG\n',T);

b01.vol=ng;
MRIwrite(b01, 'NG.nii')

close(figure(1));
hf = figure(1);
set(hf,'Name','Non-Gaussianity');
NG = [ ng(:,:,sl(1))',ng(:,:,sl(2))';ng(:,:,sl(3))',ng(:,:,sl(4))';ng(:,:, ...
    sl(5))',ng(:,:,sl(6))'];
imagesc(NG,[0,1]); colormap(MAP); colorbar; title('Non-Gaussianity-MiSFIT');
axis('equal');axis('off');axis('tight');
    cd /media/jimric/Mahdi-2022/Laxman_PD_Project/MAP_Processing/
end
