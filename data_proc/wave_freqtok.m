function k = wave_freqtok(frequency, H, wavelength_bounds, fbounds, Hbound)
%% k = WAVE_FREQTOK(frequency, H, wavelength_bounds, fbounds, Hbound)
%
%   inputs
%       - frequency: frequency, in Hz.
%       - H: bottom depth, in meters.
%       - wavelength_bounds (optional): for fzero.
%       - fbounds (optional): for fzero.
%       - Hbound (optional): for fzero.
%
%   outputs
%       - k: wavenumber, in radians per meter.


%% Define parameters

% Acceleration of gravity
g = 9.8;

% Wavelengths (in m) to use for
% wavenumber bounds in fzero
if ~exist('wavelength_bounds', 'var') || isempty(wavelength_bounds)
    wavelength_bounds = [0.1, 10000];
end

% Frequency bounds (in Hz)
if ~exist('fbounds', 'var')
    fbounds = [(1/600), (1/0.5)];
end

% Bound at very shallow water
if ~exist('Hbound', 'var')
    Hbound = 0;
end


%%

kbounds_fzero = 2*pi .* 1./wavelength_bounds;

%% Dispersion relationship
% (PS: frequency in Hz and k in radians per meter)
disp_rel = @(k, freq, H) g*k*tanh(k*H) - (2*pi*freq)^2;


%%

%
Npts_H = length(H);
Npts_freq = length(frequency);


%% Check which frequencies are good
% for the calculation of wavenumber

%
lgoodfreq = ~isnan(frequency) & ...    % this is weird to check...
            (frequency >= fbounds(1)) & ...
            (frequency <= fbounds(2));


%% Calculate frequency from wavenumber and water depth

%
k = NaN(Npts_H, Npts_freq);

%
for i1 = 1:Npts_H

    %
    H_aux = H(i1);

    %
    if isnan(H_aux) || (H_aux < Hbound)
        continue
    end

    %
    for i2 = 1:Npts_freq

        %
        if lgoodfreq(i2)

            %
            disp_rel_eval = @(k) disp_rel(k, frequency(i2), H_aux);
    
            %
            k(i1, i2) = fzero(disp_rel_eval, kbounds_fzero);

        end
    end

end



