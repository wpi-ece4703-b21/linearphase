x = [1:1024];

clf;
hold off;

% create pulse waveform
base = 1.5;     % ground frequency multiplier
sq = sin(base * 2 * pi / 60 * x) + sin(base * 2 * pi / 20 * x) / 3 + sin(base * 2 * pi / 12 * x) / 5;
figure(1)
plot(sq)

% create the modulated signal
carrier = cos(2 * pi / 4 * x);
rf      = carrier .* sq;
figure(2)
subplot(3,1,1)
plot(abs(fft(sq)))
title('Baseband Amplitude Spectrum')
subplot(3,1,2)
plot(abs(fft(rf)))
title('RF Amplitude Spectrum')

% downconvert the modulated signal
dc    = rf .* carrier;
figure(2)
subplot(3,1,3)
plot(abs(fft(dc)))
title('Downconverted signal spectrum')

% design FIR filter
Fs = 60000;              % Sampling Frequency
Fpass = 14000;           % Passband Frequency
Fstop = 16000;           % Stopband Frequency
Dpass = 0.057501127785;  % Passband Ripple
Dstop = 0.001;           % Stopband Attenuation
dens  = 20;              % Density Factor
[N, Fo, Ao, W] = firpmord([Fpass, Fstop]/(Fs/2), [1 0], [Dpass, Dstop]);
b    = firpm(N, Fo, Ao, W, {dens});
Hfir = dfilt.dffir(b);

% Design IIR filter
Apass = 1;           % Passband Ripple (dB)
Astop = 60;          % Stopband Attenuation (dB)
match = 'stopband';  % Band to match exactly
h     = fdesign.lowpass(Fpass, Fstop, Apass, Astop, Fs);
Hiir  = design(h, 'ellip', 'MatchExactly', match);

% filter the downconverted signal
yiir = filter(Hiir, dc);
yfir = filter(Hfir, dc);
figure(3)
subplot(2,1,1)
plot(yfir(1:1024));
title('FIR lowpass output')
subplot(2,1,2)
plot(yiir(1:1024));
title('IIR lowpass output')

fvtool(Hfir);
fvtool(Hiir);
