%% Make Figure 14 -- plot R asa function of (kh)_p and sigma_h/h_p.
% Contour labels are added mannually (commented out here), so this
% will differ from Fig. 14 in the paper.

clear
close all


%% Create kh and sigma/h grids

%
kh_p = logspace(log10(0.5), log10(2), 600);

%
sigma_on_h = 0 : 0.001 : 0.2;


%% Calculate k_eff * h_p (which is in the denominator of R)

%
keff_hp = NaN(length(kh_p), length(sigma_on_h));

%
fcn_find_x = @(x, A, B) x - (A*tanh(A)./tanh(x * (1 - B)));

%
for i1 = 1:length(kh_p)
    
    %
    for i2 = 1:length(sigma_on_h)
    
        %
        fcn_aux = @(x) fcn_find_x(x, kh_p(i1), sigma_on_h(i2));
        
        %
        keff_hp(i1, i2) = fzero(fcn_aux, [0.1, 6]);
         
    end
end


%% Get arguments of cosh in the numerator and in the denominator

%
[sigma_on_h_array, kh_p_array] = meshgrid(sigma_on_h, kh_p);

%
arg_num = kh_p_array;
arg_den = keff_hp .* (1 - sigma_on_h_array);


%% Compute R


R2 = (cosh(arg_num)./cosh(arg_den)).^2;

R2 = R2.';


%% Load colormap from cmocean

cmap_new = cmocean('matter');


%% Make figure


%
hfig = figure;
hfig.Units = 'normalized';
hfig.Position = [0.2, 0.2, 0.3, 0.4];
%
haxs = makeSubPlots(0.15, 0.25, 0.1, ...
                    0.1, 0.15, 0.1, 1, 1);
hold(haxs, 'on')

    %
    pcolor(kh_p, sigma_on_h, R2)

    %
    ctrs_R2 = 1:0.025:1.3;
    
    %
    [c_cf, h_cf] = contourf(kh_p, sigma_on_h, R2, ctrs_R2);
    %
    h_cf.LineStyle = 'none';

    %
    [c_aux, h_aux] = contour(kh_p, sigma_on_h, R2, ctrs_R2(2:end), 'k', 'LineWidth', 1.5);

%
shading flat
   
% ----------------------------------------
  
%
caxis([1, (1.3 + diff(ctrs_R2(1:2)))])

%
hcb = colorbar;
    hcb.Position(1) = 0.76;
    hcb.Ticks = 1:0.05:1.5;
    hcb.Label.Interpreter = 'Latex';
    hcb.Label.String = '$R$';
    hcb.Label.FontSize = 22;
    hcb.Label.Rotation = 0;
    hcb.Label.VerticalAlignment = 'middle';
    hcb.Limits = [1, 1.3];

% % % Quasi-continuous colormap
% % set(haxs, 'Colormap', cmap_new(1:end, :))

% Discrete colormap
inds_pick = round(linspace(1, 256, length(ctrs_R2)));
set(haxs, 'Colormap', cmap_new(inds_pick, :))

% ----------------------------------------
%
set(gca, 'FontSize', 14, 'Box', 'on', 'XGrid', 'on', 'YGrid', 'on')
%
set(gca, 'XScale', 'log')

ylim([0, 0.2])


% ----------------------------------------
%
xlabel('$k_p h_p$', 'Interpreter', 'Latex', 'FontSize', 22)
ylabel('$\sigma_h / h_p$', 'Interpreter', 'Latex', 'FontSize', 22)


% ----------------------------------------
% Do this at the end because it works here
%
hcb.Label.Position(1) = 3.25;
hcb.Label.Position(2) = 1.1725;

% % ----------------------------------------
% % Manually add labels to contours
% %
% hclabel = clabel(c_aux, h_aux, 'manual');
% %
% for i = 1:length(hclabel)
%     hclabel(i).FontSize = 18;
%     hclabel(i).Color = [1, 0, 0];
%     if i~=length(hclabel)
%         hclabel(i).Rotation = 0;
%     end
% end



%% Save figure

%
dir_output = fullfile(paper_directory(), 'figures');
                  
%
exportgraphics(hfig, fullfile(dir_output, 'figure14.pdf'), 'Resolution', 300)

