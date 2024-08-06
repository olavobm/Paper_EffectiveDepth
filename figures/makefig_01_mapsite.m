%% Make Figure 01 -- plot map of the study site with instrument locations

clear
close all


%% Load bathymetry

%
bathymetry = load(fullfile(paper_directory(), 'data', 'bathymetry', 'zmsl_ChinaRock_gridded.mat'));
bathymetry = bathymetry.bathymetry;


%% Load point cloud bathymetry around E05

%
elevroxsi = load(fullfile(paper_directory(), 'data', 'bathymetry', 'roxsi_pointcloud_E05.mat'));
elevroxsi = elevroxsi.elevroxsi;


%% Load mooring locations

%
load(fullfile(paper_directory(), 'data_proc', 'ROXSI2022_mooringtable.mat'))


%% Load photo

%
photo_ChinaRock = imread(fullfile(paper_directory(), 'figures', 'photo_shoreline.jpg'));


%% 
% ------------------------------
% ----- EDIT MOORING TABLE -----
% ------------------------------

%
mooringtable = mooringtable(strcmp(mooringtable.roxsiarray, "ChinaRock"), :);
mooringtable = mooringtable(~strcmp(mooringtable.mooringID, "ISPAR"), :);

% Remove t-chains
mooringtable = mooringtable(~strcmp(mooringtable.instrument, "tchain"), :);



%%

%
simpleID = strings(length(mooringtable.mooringID), 1);
%
for i = 1:length(mooringtable.mooringID)
    %
    id_aux = char(mooringtable.mooringID(i));
    %
    simpleID(i) = convertCharsToStrings(id_aux(1:3));
end

%
mooringtable.simpleID = simpleID;


%% No data from pressure sensors at these sites

%
lkeep = ~strcmp(mooringtable.simpleID, "C04") & ...
        ~strcmp(mooringtable.simpleID, "A08");

%
mooringtable = mooringtable(lkeep, :);



%% For bathy around E05

%
ind_match = find(strcmp(mooringtable.mooringID, "E05sp"));

%
mean_depth = 9.7;

%
dx = 25;

%
lin_region = (elevroxsi.x >= (mooringtable.x(ind_match) - (dx+5))) & ...
             (elevroxsi.x <= (mooringtable.x(ind_match) + (dx+5)))  & ...
             (elevroxsi.y >= (mooringtable.y(ind_match) - (dx+5))) & ...
             (elevroxsi.y <= (mooringtable.y(ind_match) + (dx+5)));
         
         
         
%% To create a circle around E05

%
r0 = 10;
Nangles = 200;
thetavec = linspace(0, 2*pi, Nangles);
%
cosvec = cos(thetavec);
sinvec = sin(thetavec);
               

%% 
% ------------------------------
% --- CREATE USEFUL COLORMAP ---
% ------------------------------

%%

%
figure, cmocean topo;
cmap_topo = get(gca, 'Colormap');
colorbar
close(gcf)


%%

%
zbottom = -22;
ztop = 10;

%
% inds_trim_ocean = 24:128;
inds_trim_ocean = 24:124;
inds_trim_land = 129:256;


%%

%
dz = 1;
%
Nlvls = length(zbottom:dz:ztop);
Nlvls_ocean = length(zbottom:dz:0);
Nlvls_land = length(0:dz:ztop);

%
inds_ocean_interp = linspace(inds_trim_ocean(1), inds_trim_ocean(end), Nlvls_ocean+1);
inds_land_interp = linspace(inds_trim_land(1), inds_trim_land(end), Nlvls_land);

%
cmap_ocean = interp1(inds_trim_ocean, cmap_topo(inds_trim_ocean, :), inds_ocean_interp);
cmap_land = interp1(inds_trim_land, cmap_topo(inds_trim_land, :), inds_land_interp);

%
cmap_new = [cmap_ocean; cmap_land];


%%

%
figure, cmocean balance;
cmap_redblue = get(gca, 'Colormap');
colorbar
close(gcf)


%%
% ---------------------------------------------------------------------
% ---------------------------------------------------------------------
% ---------------------------- MAKE FIGURE ----------------------------
% ---------------------------------------------------------------------
% ---------------------------------------------------------------------

%
dir_output = fullfile(paper_directory(), 'figures');



%%

%
xWidth = 8;
% % xWidth = 16;    % full page
yHeight = 13;

%
hfig = figure;
hfig.Units = 'normalized';
hfig.Position = [0.2795    0.0542    0.1577    0.6];
%
hfig.PaperUnits = 'centimeters';
hfig.PaperPosition = [0, 0, xWidth, yHeight];

%
widthheight = 0.62;
%
haxs_a = axes('Position', [0.21, 0.605, widthheight, widthheight]);
haxs_b = axes('Position', [0.21, 0.31, widthheight, widthheight]);
haxs_c = axes('Position', [0.21, -0.094, widthheight, widthheight]);
%
haxs_all = [haxs_a, haxs_b, haxs_c];
%
hold([haxs_b, haxs_c], 'on')    % if include haxs_a, it deals with Y axis
                                % direction in the standard way for axis,
                                % which is the opposite than for images.
                                
% ----------------------------------------------------

% -----------------------
    image(haxs_a, photo_ChinaRock)

    hold(haxs_a, 'on')
    
% -----------------------
    %
    pcolor(haxs_b, bathymetry.x, bathymetry.y, bathymetry.z_msl)

    %
    contour(haxs_b, bathymetry.x, bathymetry.y, bathymetry.z_msl, [-10, -10], 'k')

  
    %
    plot(haxs_b, mooringtable.x, mooringtable.y, '.', 'Color', [0, 0, 0], 'MarkerSize', 28)
    
    %
    lsmartmooring = strcmp(mooringtable.instrument, "smartspotter") & ~strcmp(mooringtable.mooringID, "E10sp");

    %
    plot(haxs_b, mooringtable.x(lsmartmooring), mooringtable.y(lsmartmooring), '.k', 'MarkerSize', 48)
    plot(haxs_b, mooringtable.x(lsmartmooring), mooringtable.y(lsmartmooring), '.y', 'MarkerSize', 38)
    

% -----------------------


        % ------------------------------------
        
        % Remove dots at the axes edges behind colorbar so
        % it doesn't look ugly behind colorbar 
        %
        lbelow_colorbar = (elevroxsi.x > -359) & (elevroxsi.y < -170);
        %
        lin_region = lin_region & ~lbelow_colorbar;
        
        %
        scatter(haxs_c, elevroxsi.x(lin_region), elevroxsi.y(lin_region), 7, ...
                       (elevroxsi.z_msl(lin_region) + mean_depth), 'filled')
                      
        %
        plot(haxs_c, mooringtable.x(ind_match), mooringtable.y(ind_match), '.k', 'MarkerSize', 58)
        plot(haxs_c, mooringtable.x(ind_match), mooringtable.y(ind_match), '.y', 'MarkerSize', 48)
        %
        for i = 1:length(r0)
            plot(haxs_c, mooringtable.x(ind_match) + r0(i).*cosvec, ...
                           mooringtable.y(ind_match) + r0(i).*sinvec, ...
                           '-k', 'LineWidth', 3)
        end
               
 
% -----------------------

%
shading(haxs_b, 'flat')
shading(haxs_c, 'flat')

    
% ----------------------------------------------------

    %
    xlbl = [-650, -600, -550, -500, -520, -480, -500, -500];
    indypick = find(lsmartmooring);
    indypick = indypick(1:end);
    ylbl = mooringtable.y(indypick);    ylbl = ylbl(:).';
    %
    ylbl(6) = 100;
    %
    txtlbls = ["S1", "S2", "S3", "S4", "S5", "S6", "S7", "S8"];
    
    %
    for i = 1:length(txtlbls)
        text(haxs_b, xlbl(i), ylbl(i), txtlbls(i), 'Color', 'y', 'FontSize', 18)
    end
    
    
% ----------------------------------------------------

%
text(haxs_c, -400, -143, 'S3', 'Color', 'y', 'FontSize', 26)


% ----------------------------------------------------

%
plt_arrow(haxs_b, 1.2, ...
                  0, 140, -16, -30)


% ----------------------------------------------------
    
%
xcb = 0.78;
wdb = 0.05;
cbtcksFS = 11;
    
%
hcb_1 = colorbar(haxs_b);
    %
    hcb_1.FontSize = cbtcksFS;
    %
    hcb_1.Position(1) = xcb;
    hcb_1.Position(2) = 0.421;
    hcb_1.Position(3) = wdb;
    hcb_1.Position(4) = 0.2;

    %
    hcb_2 = colorbar(haxs_c);
        hcb_2.FontSize = cbtcksFS;
        hcb_2.Ticks = -4:2:4;
        hcb_2.Position = [xcb, 0.069, wdb, 0.15];
    %
    colormap(haxs_b, cmap_new)
    caxis(haxs_b, [zbottom, ztop])
    
    %
    colormap(haxs_c, cmap_redblue)
    set(haxs_c, 'CLim', [-4, 4])
    
%
hcb_1.Label.String = '[m]';
hcb_2.Label.String = '[m]';
%
hcb_1.Label.FontSize = 14;
hcb_2.Label.FontSize = 14;
%
hcb_1.Label.Interpreter = 'Latex';
hcb_2.Label.Interpreter = 'Latex';
%
hcb_1.Label.Rotation = 0;
hcb_2.Label.Rotation = 0;
%
hcb_1.Label.VerticalAlignment = 'middle';
hcb_2.Label.VerticalAlignment = 'middle';

%
hcb_2.Label.Position(1) = hcb_1.Label.Position(1);

% ----------------------------------------------------


    %
    set(haxs_all, 'DataAspectRatio', [1, 1, 1])
    %
    set([haxs_b, haxs_c], 'FontSize', 12, 'Box', 'on', 'XGrid', 'on', 'YGrid', 'on')
    
    %
    photo_xlims = [250, 1400];
    %
    photo_ylims = [200, 800];
    %
    set(haxs_a, 'XLim', photo_xlims, 'YLim', photo_ylims)
    
    %
    set(haxs_b, 'XLim', [-750, 50], 'YLim', [-625, 400])

    %
    set(haxs_a, 'XTickLabel', [], 'YTickLabel', [])
    
    %
    set(haxs_c, 'XLim', [-410, -355], 'YLim', [-190, -138])
	set(haxs_c, 'XTick', -410:20:340, 'YTick', -190:20:-130)
            
    %
    set([haxs_b, haxs_c], 'Color', 0.4*[1, 1, 1])
    
    
% ----------------------------------------------------

%
ylabel(haxs_b, '$y$ [m]', 'Interpreter', 'Latex', 'FontSize', 16)

%
xlabel(haxs_c, '$x$ [m]', 'Interpreter', 'Latex', 'FontSize', 16)
ylabel(haxs_c, '$y$ [m]', 'Interpreter', 'Latex', 'FontSize', 16)


% ----------------------------------------------------
%
xedge_1 = 250;
xedge_2 = -750;
xedge_3 = -410;
%
xsl_1 = [xedge_1, xedge_1, xedge_1 + 0.13*diff(haxs_a.XLim).*[1, 1], xedge_1];
xsl_2 = [xedge_2, xedge_2, xedge_2 + 0.13*diff(haxs_b.XLim).*[1, 1], xedge_2];
xsl_3 = [xedge_3, xedge_3, xedge_3 + 0.13*diff(haxs_c.XLim).*[1, 1], xedge_3];
%
ysl_1 = [350, 200, 200, 350, 350];
ysl_2 = [300, 400, 400, 300, 300];
ysl_3 = [-145, -138, -138, -145, -145];

%
hsqf_1 = fill(haxs_a, xsl_1, ysl_1, 'w');
hsqf_2 = fill(haxs_b, xsl_2, ysl_2, 'w');
hsqf_3 = fill(haxs_c, xsl_3, ysl_3, 'w');

%
htl1 = text(haxs_a, haxs_a.XLim(1) + 0.01*diff(haxs_a.XLim), mean(ysl_1(1:2)), 'a)', 'FontSize', 20);
htl2 = text(haxs_b, haxs_b.XLim(1) + 0.01*diff(haxs_b.XLim), mean(ysl_2(1:2)), 'b)', 'FontSize', 20);
htl3 = text(haxs_c, haxs_c.XLim(1) + 0.01*diff(haxs_c.XLim), mean(ysl_3(1:2)), 'c)', 'FontSize', 20);


%% Save figure

%
exportgraphics(hfig, fullfile(dir_output, 'figure01.pdf'), 'Resolution', 300)
