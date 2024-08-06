%% Make Figure 06 -- probability density function of bottom depth

clear
close all


%% Load mooring table

load(fullfile(paper_directory(), 'data_proc', 'smartmooring_table.mat'))


%% Load bathymetry


elevroxsi = load(fullfile(paper_directory(), 'data', 'bathymetry', 'roxsi_pointcloud_E05.mat'));
elevroxsi = elevroxsi.elevroxsi;


%% Select instrument site

%
ind_match = find(strcmp(mooringtable.mooringID, "E05"));

%
mean_depth = 9.7;    % see mooringtable.h_mean



%% Select bottom depth within radius r0

%
dist_aux = sqrt((elevroxsi.x - mooringtable.X(ind_match)).^2 + ...
                (elevroxsi.y - mooringtable.Y(ind_match)).^2);

%
r0 = 10;
            
%
lwithin_r0 = (dist_aux <= r0);

%
bathysub.x = elevroxsi.x(lwithin_r0);
bathysub.y = elevroxsi.y(lwithin_r0);
bathysub.z_msl = elevroxsi.z_msl(lwithin_r0);
%
bathysub.z_msl = -bathysub.z_msl;
        


%% Make figure

%
hfig = figure;
hfig.Units = 'normalized';
hfig.Position = [0.2350    0.1683    0.2350    0.3992];
haxs_pdf = makeSubPlots(0.15, 0.02, 0.02, ...
                        0.125, 0.125, 0.1, 1, 1);
hold(haxs_pdf, 'on')

    % ------------------------------------
    %
    hhist = histogram(haxs_pdf, bathysub.z_msl, 'Normalization', 'pdf');

    %
    ylims_aux = ylim(haxs_pdf);

    %
    hp_color = [0.9290 0.75 0.1250];
    mean_color = [0.9, 0.1, 0.2];

    %
    plot(haxs_pdf, mean_depth.*[1, 1], ylims_aux, '-', 'Color', hp_color, 'LineWidth', 4)
    %
    plot(haxs_pdf, mean(bathysub.z_msl).*[1, 1], ylims_aux, '-', 'Color', mean_color, 'LineWidth', 4)
    plot(haxs_pdf, median(bathysub.z_msl).*[1, 1], ylims_aux, '-k', 'LineWidth', 4)
    %
    z_quants = quantile(bathysub.z_msl, [0.25, 0.75]);
    %
    plot(haxs_pdf, z_quants(1).*[1, 1], ylims_aux, '--k', 'LineWidth', 2)
    plot(haxs_pdf, z_quants(2).*[1, 1], ylims_aux, '--k', 'LineWidth', 2)

    % ------------------------------------

    %
    xrect = [5.1, 5.1, 7.5, 7.5, 5.1];
    yrect = [0.3, 0.4925, 0.4925, 0.3, 0.3];
    %
    hrect = fill(xrect, yrect, 'w');

    %
    x_lines = [5.15, 6];
    %
    y_1_aux = 0.47;
    dy = -0.05;
    %
    y_2_aux = y_1_aux + dy;
    y_3_aux = y_2_aux + dy;
    y_4_aux = y_3_aux + dy;

    %
    lnWDleg = 4;
    %
    plot(haxs_pdf, x_lines, y_1_aux.*[1, 1], '-', 'Color', mean_color, 'LineWidth', lnWDleg)
    plot(haxs_pdf, x_lines, y_2_aux.*[1, 1], '-k', 'LineWidth', lnWDleg)
    plot(haxs_pdf, x_lines, y_3_aux.*[1, 1], '--k', 'LineWidth', lnWDleg)
    plot(haxs_pdf, x_lines, y_4_aux.*[1, 1], '-', 'Color', hp_color, 'LineWidth', lnWDleg)
    %
    xdispname = 0.115;
    text(x_lines(2)+xdispname, y_1_aux, 'mean($h$)', 'Interpreter', 'Latex', 'FontSize', 14)
    text(x_lines(2)+xdispname, y_2_aux, 'median($h$)', 'Interpreter', 'Latex', 'FontSize', 14)
    text(x_lines(2)+xdispname, y_3_aux, 'quantile($h$)', 'Interpreter', 'Latex', 'FontSize', 14)
    text(x_lines(2)+xdispname, y_4_aux, '$\overline{h}_p$', 'Interpreter', 'Latex', 'FontSize', 14)

% ------------------------------------    

%
set(haxs_pdf, 'FontSize', 14, 'Box', 'on', 'XGrid', 'on', 'YGrid', 'on')
set(haxs_pdf, 'XLim', [5, 11.5])
set(haxs_pdf, 'YLim', ylims_aux)
set(haxs_pdf, 'XTick', 5:1:11)
%
set(haxs_pdf, 'Color', 0.9.*[1, 1, 1])

% ------------------------------------


%
xlabel(haxs_pdf, '$h$ [m]', 'Interpreter', 'Latex', 'FontSize', 18)
ylabel(haxs_pdf, 'Probability density [m$^{-1}$]', 'Interpreter', 'Latex', 'FontSize', 18)
%
title(haxs_pdf, ['Bottom depth ($h$) within $r = 10~\mathrm{m}$ of ' idfield_to_idpaper('E05')], 'Interpreter', 'Latex', 'FontSize', 16)
    
        
%%

%
dir_output = fullfile(paper_directory(), 'figures');


% 
exportgraphics(hfig, fullfile(dir_output, 'figure06.pdf'), 'Resolution', 300)
        
        
        

