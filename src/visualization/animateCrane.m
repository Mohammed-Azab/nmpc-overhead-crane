function animateCrane(X, T_s, varargin)
% ANIMATECRANE  Animate the overhead crane from a state trajectory.
%   X = [x_load, v_load, x_crane, v_crane]  (one row per time step)
%
%   Example:
%     animateCrane(X, 0.05, 'Ref', ref, 'Input', u, ...
%                  'CableLength', 2, 'Speed', 1, ...
%                  'Record', 'results/demo.gif', 'GifStride', 3, 'GifScale', 0.6);

    p = inputParser;
    addParameter(p, 'CableLength', 2);
    addParameter(p, 'Speed', 1);
    addParameter(p, 'Ref', []);
    addParameter(p, 'Input', []);
    addParameter(p, 'Trail', true);
    addParameter(p, 'Record', '');
    addParameter(p, 'Title', 'Overhead crane');
    addParameter(p, 'Parent', []);
    addParameter(p, 'GifStride', 3);
    addParameter(p, 'GifScale', 0.6);
    addParameter(p, 'Music', false);      % sonify the swing (pentatonic + harmonics)
    addParameter(p, 'MusicFile', '');     % play this audio file instead (wav/mp3/...)
    addParameter(p, 'Muted', true);       % start muted (toggle with the speaker button)
    parse(p, varargin{:});
    opt = p.Results;

    if size(X,2) ~= 4 && size(X,1) == 4
        X = X.';
    end
    assert(size(X,2) == 4, 'X must have 4 columns: [x_load, v_load, x_crane, v_crane].');

    x_load  = X(:,1);
    v_load  = X(:,2);
    x_crane = X(:,3);
    v_crane = X(:,4);
    N = size(X,1);
    L = opt.CableLength;

    dx = x_load - x_crane;
    dx = max(min(dx, L*0.999), -L*0.999);
    y_load = -sqrt(L.^2 - dx.^2);
    theta  = asind(dx ./ L);

    % light palette
    accent = [0.29 0.33 0.62];   % indigo  (header, trolley, button)
    amber  = [0.90 0.49 0.13];   % payload
    trailC = [0.36 0.56 0.90];   % swing trail
    railC  = [0.28 0.30 0.36];   % gantry
    cableC = [0.33 0.35 0.42];   % cable
    tgtC   = [0.85 0.20 0.27];   % target
    ink    = [0.16 0.17 0.22];   % text
    hair   = [0.85 0.86 0.90];   % light borders
    fontName = 'Times New Roman';

    % figure / axes 
    ownFig = isempty(opt.Parent);
    if ownFig
        fig = figure('Color','w','Name','Overhead crane', ...
                     'Units','normalized','Position',[0.06 0.10 0.88 0.80]);
        ax  = axes('Parent',fig,'Units','normalized','Position',[0.055 0.13 0.70 0.78]);
    else
        ax  = opt.Parent;
        fig = ancestor(ax,'figure');
    end

    set(fig, 'Color', 'w');
    set(fig, 'DefaultAxesFontName',fontName, 'DefaultTextFontName',fontName, ...
             'DefaultUicontrolFontName',fontName);
    try, theme(fig, 'light'); catch, end   %#ok<CTCH>
    set(ax, 'Color','w', 'XColor',ink, 'YColor',ink, ...
            'GridColor',[0.6 0.6 0.65], 'GridAlpha',0.15, 'LineWidth',1);

    hold(ax,'on'); box(ax,'on'); grid(ax,'on');
    set(ax,'FontSize',12,'FontName',fontName);
    axis(ax,'equal');

    refVec = opt.Ref(:).';
    xspan = max([max(abs([x_load; x_crane])) + 1, abs(refVec), 4]);
    xlim(ax, [-xspan, xspan]);
    ylim(ax, [-(L+0.7), 1.0]);
    xlabel(ax,'horizontal position  x  [m]','FontSize',13,'Color',ink,'FontName',fontName);
    ylabel(ax,'height  [m]','FontSize',13,'Color',ink,'FontName',fontName);
    title(ax, opt.Title,'FontSize',16,'FontWeight','bold','Color',ink,'FontName',fontName);

    % gantry rail with end supports
    plot(ax, [-xspan xspan], [0 0], '-', 'Color',railC, 'LineWidth', 4);
    plot(ax, [-xspan -xspan], [0 0.30], '-', 'Color',railC, 'LineWidth', 4);
    plot(ax, [ xspan  xspan], [0 0.30], '-', 'Color',railC, 'LineWidth', 4);

    % target line + marker
    targetLine = []; targetMark = [];
    if ~isempty(refVec)
        targetLine = plot(ax, [refVec(1) refVec(1)], ylim(ax), '--', ...
                          'Color',tgtC, 'LineWidth', 1.5);
        targetMark = plot(ax, refVec(1), -L, 'x', 'Color',tgtC, ...
                          'MarkerSize', 15, 'LineWidth', 2.5);
    end

    % trail
    trail = [];
    if opt.Trail
        trail = plot(ax, x_load(1), y_load(1), '-', 'Color', trailC, 'LineWidth', 1.4);
    end

    % cable, trolley, load
    cable   = plot(ax, [x_crane(1) x_load(1)], [0 y_load(1)], '-', 'Color',cableC, 'LineWidth', 2);
    trolley = rectangle('Parent',ax, 'Position', troPos(x_crane(1)), ...
                   'FaceColor', accent, 'EdgeColor',accent*0.7, 'LineWidth',1, 'Curvature', 0.3);
    load    = rectangle('Parent',ax, 'Position', loadPos(x_load(1), y_load(1)), ...
                   'FaceColor', amber, 'EdgeColor',amber*0.7, 'LineWidth',1, 'Curvature', 0.15);

    % input arrow
    inpArrow = [];
    if ~isempty(opt.Input)
        u = opt.Input(:).';
        uscale = 0.6 / max(max(abs(u)), eps);
        inpArrow = quiver(ax, x_crane(1), 0.55, u(1)*uscale, 0, 0, ...
                          'Color',accent, 'LineWidth', 2, 'MaxHeadSize', 3);
    end

    % ---- right column: compact status card + legend + replay button -------
    if ownFig
        % small legend chip (top)
        if ~isempty(targetMark)
            lg = legend(ax, targetMark, 'target x_{load}', 'FontSize',10);
            set(lg, 'TextColor',ink, 'Color','w', 'EdgeColor',hair, 'FontName',fontName, ...
                    'Units','normalized', 'Position',[0.79 0.905 0.155 0.045]);
        end

        cardAx = axes('Parent',fig,'Units','normalized','Position',[0.775 0.55 0.185 0.33]);
        set(cardAx,'XLim',[0 1],'YLim',[0 1],'XTick',[],'YTick',[], ...
                   'Box','on','Color','w','XColor',hair,'YColor',hair,'Clipping','on');
        patch(cardAx,[0 1 1 0],[0.86 0.86 1 1], accent, 'EdgeColor','none');   % header strip
        text(cardAx,0.06,0.93,'STATUS','Color','w','FontWeight','bold', ...
             'FontUnits','normalized','FontSize',0.085,'FontName',fontName, ...
             'VerticalAlignment','middle','Clipping','on');
        infoTxt = text(cardAx,0.06,0.80,'','Interpreter','tex', ...
             'FontUnits','normalized','FontSize',0.062,'FontName',fontName, ...
             'Color',ink,'VerticalAlignment','top','Clipping','on');
        setInfo = @(lines) set(infoTxt,'String',lines);
        line(cardAx,[0.06 0.94],[0.20 0.20],'Color',hair,'LineWidth',0.5);     % divider

        % borderless icon controls sitting on the white figure
        isz = 160;                                            % build big, render small = crisp
        [sqC, sqA] = squareIconRGBA(isz, [0.82 0.24 0.24]);   % red stop square
        [trC, trA] = triIconRGBA(isz,   [0.18 0.58 0.33]);    % green resume triangle
        iconPath = fullfile(fileparts(fileparts(fileparts(mfilename('fullpath')))), ...
                            'assets', 'replay.png');
        if isfile(iconPath)
            [rpC, rpA] = loadPngRGBA(iconPath, isz);
        else
            rpC = replayIconCData(isz, ink);
            rpA = double(~isnan(rpC(:,:,1)));
            rpC(isnan(rpC)) = 1;
        end

        % compact icons placed INSIDE the status card, below the data divider
        iw = 0.028;  yb = 0.566;                              % icon width / bottom (normalised)
        % play / pause toggle: red square while playing, triangle while paused
        playAx  = axes('Parent',fig,'Units','normalized','Position',[0.833 yb iw iw],'Color','none');
        playImg = image('Parent',playAx,'CData',sqC,'AlphaData',sqA);
        axis(playAx,'image'); axis(playAx,'off');
        set([playAx playImg],'ButtonDownFcn',@(~,~) togglePlay());

        % replay: restart from the beginning at any time
        replayAx  = axes('Parent',fig,'Units','normalized','Position',[0.873 yb iw iw],'Color','none');
        replayImg = image('Parent',replayAx,'CData',rpC,'AlphaData',rpA);
        axis(replayAx,'image'); axis(replayAx,'off');
        set([replayAx replayImg],'ButtonDownFcn',@(~,~) doReplay());

        % mute / unmute toggle
        [muOnC, muOnA ] = speakerIconRGBA(isz, ink, true);
        [muOffC,muOffA] = speakerIconRGBA(isz, ink, false);
        musicImg = [];
        if ~isempty(opt.MusicFile) || opt.Music
            if opt.Muted, mC = muOffC; mA = muOffA; else, mC = muOnC; mA = muOnA; end
            musicAx  = axes('Parent',fig,'Units','normalized','Position',[0.793 yb iw iw],'Color','none');
            musicImg = image('Parent',musicAx,'CData',mC,'AlphaData',mA);
            axis(musicAx,'image'); axis(musicAx,'off');
            set([musicAx musicImg],'ButtonDownFcn',@(~,~) toggleMusic());
        end
    else
        txt = text(ax, 0.015, 0.97, '', 'Units','normalized', 'Interpreter','tex', ...
               'FontName',fontName,'FontSize',12, ...
               'VerticalAlignment','top','HorizontalAlignment','left', ...
               'Color',ink,'BackgroundColor',[1 1 1],'EdgeColor',hair,'LineWidth',1,'Margin',7);
        setInfo = @(lines) set(txt,'String',lines);
    end

    % playback
    dt   = max(T_s / max(opt.Speed, eps), 0.02);
    kk   = 0;
    anim = timer('ExecutionMode','fixedRate','Period',dt,'BusyMode','drop', ...
                 'TimerFcn',@(~,~) onTick());
    if ownFig
        set(fig,'CloseRequestFcn',@(~,~) onClose());
    end

    % swing sonification: the pendulum angle drives a pentatonic pitch (+ harmonics),
    % so the audio literally traces the swing wave.
    player = [];
    if ~isempty(opt.MusicFile)
        try
            [snd, fs] = audioread(opt.MusicFile);   % your own song, played in sync
            player = audioplayer(snd, fs);
        catch
            warning('animateCrane:music', 'Could not read music file: %s', opt.MusicFile);
            player = [];
        end
    elseif opt.Music
        try
            [music, fs] = swingMusic(theta, N*dt);  % generated swing sonification
            player = audioplayer(music, fs);
        catch
            player = [];
        end
    end

    muted = logical(opt.Muted);      % music mute state (music follows the motion)

    if ~isempty(opt.Record)
        recordRun();                 % blocking: write the file once (no audio)
        kk = N;                      % leave at final frame, paused
        setPlayIcon('paused');
    else
        start(anim);  aPlay();       % auto-play; music plays while it swings
    end

    function onTick()
        kk = kk + 1;
        if kk > N                    % motion finished -> stop everything
            stop(anim);  aStop();  setPlayIcon('paused');
            return;
        end
        drawFrame(kk);
    end

    function togglePlay()
        if strcmp(anim.Running,'on')
            stop(anim);  setPlayIcon('paused');  aPause();
        else
            if kk >= N, kk = 0; aStop(); aPlay(); else, aResume(); end
            start(anim); setPlayIcon('playing');
        end
    end

    function doReplay()              % restart motion (and music) from the beginning
        stop(anim);  kk = 0;  aStop();  aPlay();  start(anim);  setPlayIcon('playing');
    end

    % ---- audio helpers (respect the mute toggle) ----
    function aPlay()
        if ~isempty(player) && ~muted, try, play(player); catch, end, end   %#ok<CTCH>
    end
    function aResume()
        if isempty(player) || muted, return; end
        try, resume(player); catch, try, play(player); catch, end, end       %#ok<CTCH>
    end
    function aPause()
        if ~isempty(player), try, pause(player); catch, end, end             %#ok<CTCH>
    end
    function aStop()
        if ~isempty(player), try, stop(player); catch, end, end              %#ok<CTCH>
    end

    function toggleMusic()
        if isempty(player), return; end
        muted = ~muted;
        if muted
            aPause();  setMusicIcon(false);
        else
            if strcmp(anim.Running,'on'), aResume(); end
            setMusicIcon(true);
        end
    end

    function setMusicIcon(on)
        if isempty(musicImg) || ~ishandle(musicImg), return; end
        if on, set(musicImg,'CData',muOnC, 'AlphaData',muOnA);
        else,  set(musicImg,'CData',muOffC,'AlphaData',muOffA); end
    end

    function setPlayIcon(mode)
        if ~ownFig || ~ishandle(playImg), return; end
        if strcmp(mode,'playing')
            set(playImg,'CData',sqC,'AlphaData',sqA);   % red square -> click to stop
        else
            set(playImg,'CData',trC,'AlphaData',trA);   % triangle   -> click to resume
        end
    end

    function onClose()
        try, stop(anim); delete(anim); catch, end   %#ok<CTCH>
        if ~isempty(player), try, stop(player); catch, end, end   %#ok<CTCH>
        delete(fig);
    end

    function drawFrame(k)
        set(cable,   'XData', [x_crane(k) x_load(k)], 'YData', [0 y_load(k)]);
        set(trolley, 'Position', troPos(x_crane(k)));
        set(load,    'Position', loadPos(x_load(k), y_load(k)));
        if ~isempty(trail)
            set(trail, 'XData', x_load(1:k), 'YData', y_load(1:k));
        end
        if ~isempty(targetLine)
            r = refVec(min(k, numel(refVec)));
            set(targetLine, 'XData', [r r]);
            set(targetMark, 'XData', r);
        end
        if ~isempty(inpArrow)
            uk = u(min(k, numel(u)));
            set(inpArrow, 'XData', x_crane(k), 'UData', uk*uscale);
        end
        lines = { sprintf('t = %.2f s', (k-1)*T_s), ...
                  sprintf('x_{load} = %.2f m', x_load(k)), ...
                  sprintf('v_{load} = %.2f m/s', v_load(k)), ...
                  sprintf('x_{crane} = %.2f m', x_crane(k)), ...
                  sprintf('v_{crane} = %.2f m/s', v_crane(k)), ...
                  sprintf('swing = %.2f m  (%.1f^{\\circ})', dx(k), theta(k)) };
        if ~isempty(opt.Input)
            lines{end+1} = sprintf('u = %.2f', u(min(k,numel(u))));
        end
        setInfo(lines);
        drawnow limitrate;
    end

    function recordRun()
        isGif  = endsWith(lower(opt.Record), '.gif');
        writer = [];
        if ~isGif
            if endsWith(lower(opt.Record),'.mp4')
                writer = VideoWriter(opt.Record,'MPEG-4');
            else
                writer = VideoWriter(opt.Record);
            end
            writer.FrameRate = max(1, round(opt.Speed/T_s));
            open(writer);
        end
        gifWritten = 0;
        for k = 1:N
            drawFrame(k); drawnow;
            if ~isempty(writer)
                writeVideo(writer, getframe(fig));
            elseif mod(k-1, max(1,round(opt.GifStride))) == 0
                im = frame2im(getframe(fig));
                if opt.GifScale ~= 1 && exist('imresize','file')
                    im = imresize(im, opt.GifScale);
                end
                [Aidx, cmap] = rgb2ind(im, 128);
                delay = max(opt.GifStride*dt, 0.03);
                if gifWritten == 0
                    imwrite(Aidx, cmap, opt.Record, 'gif', 'LoopCount', Inf, 'DelayTime', delay);
                else
                    imwrite(Aidx, cmap, opt.Record, 'gif', 'WriteMode', 'append', 'DelayTime', delay);
                end
                gifWritten = gifWritten + 1;
            end
        end
        if ~isempty(writer)
            close(writer);
            fprintf('Saved animation to %s\n', opt.Record);
        else
            fprintf('Saved animation to %s (%d frames)\n', opt.Record, gifWritten);
        end
    end

    % geometry helpers
    function pos = troPos(xc)
        w = 0.5; h = 0.18;
        pos = [xc - w/2, -h/2, w, h];
    end
    function pos = loadPos(xl, yl)
        s = 0.4;
        pos = [xl - s/2, yl - s/2, s, s];
    end
end

function [C, A] = loadPngRGBA(fpath, sz)
% loadPngRGBA  Load an icon PNG as [rgb, alpha], both in [0,1], resized to sz.
    [img, ~, alpha] = imread(fpath);
    img = im2double(img);
    if size(img,3) == 1, img = repmat(img, 1, 1, 3); end
    if nargin >= 2 && ~isempty(sz) && exist('imresize','file')
        img = imresize(img, [sz sz]);
        if ~isempty(alpha), alpha = imresize(alpha, [sz sz]); end
    end
    C = img;
    if ~isempty(alpha)
        A = im2double(alpha);                % use file transparency
    else
        A = double(~all(img > 0.95, 3));     % white background -> transparent
    end
end

function [C, A] = squareIconRGBA(sz, col)
% squareIconRGBA  Filled square icon (rgb + alpha).
    C = cat(3, col(1)*ones(sz), col(2)*ones(sz), col(3)*ones(sz));
    A = zeros(sz);
    m = max(1, round(sz*0.20));
    A(m:sz-m+1, m:sz-m+1) = 1;
end

function [C, A] = triIconRGBA(sz, col)
% triIconRGBA  Right-pointing play triangle icon (rgb + alpha).
    C = cat(3, col(1)*ones(sz), col(2)*ones(sz), col(3)*ones(sz));
    [xx, yy] = meshgrid(1:sz, 1:sz);
    x = (xx-1)/(sz-1);  y = (yy-1)/(sz-1);   % [0,1]
    m = 0.22;  Hb = 0.30;                    % margins / base half-height
    inside = x >= m & x <= 1-m & abs(y-0.5) <= Hb .* (1-m - x) ./ (1-2*m);
    A = double(inside);
end

function C = replayIconCData(sz, col)
% replayIconCData  RGB icon (loop arrow + play triangle); NaN = transparent.
    if nargin < 1, sz  = 34;        end
    if nargin < 2, col = [0 0 0];   end
    [xx, yy] = meshgrid(1:sz, 1:sz);
    c = (sz+1)/2;
    x = xx - c;   y = yy - c;
    r = hypot(x, y);
    ang = atan2(-y, x);                         % math angle (CCW, y up)

    Ro = 0.44*sz;  Ri = 0.31*sz;  Rm = (Ro+Ri)/2;
    gapLo = deg2rad(40);  gapHi = deg2rad(95);  % opening at upper right
    ring = (r <= Ro & r >= Ri) & ~(ang > gapLo & ang < gapHi);

    % arrowhead at the clockwise end of the ring (a small filled triangle)
    tip  = [ Rm*cos(gapLo-0.55), -Rm*sin(gapLo-0.55) ];
    base1 = [ (Ro+0.06*sz)*cos(gapLo), -(Ro+0.06*sz)*sin(gapLo) ];
    base2 = [ (Ri-0.06*sz)*cos(gapLo), -(Ri-0.06*sz)*sin(gapLo) ];
    head = inTri(x, y, tip, base1, base2);

    % play triangle in the centre (points right)
    aL = 0.13*sz;  bR = 0.21*sz;  H = 0.17*sz;
    tri = (x >= -aL & x <= bR) & (abs(y) <= H .* (bR - x) ./ (bR + aL));

    mask = ring | head | tri;
    C = nan(sz, sz, 3);
    for ch = 1:3
        layer = nan(sz, sz);
        layer(mask) = col(ch);
        C(:,:,ch) = layer;
    end
end

function [y, fs] = swingMusic(sig, dur)
% swingMusic  Sonify the swing: pitch (pentatonic) traces the signal, plus overtones.
    fs = 22050;
    L  = max(round(dur*fs), fs);                 % at least 1 s of audio
    sig = sig(:);
    if numel(sig) < 2, sig = [sig; sig]; end
    s  = interp1(linspace(0,1,numel(sig)), sig, linspace(0,1,L), 'pchip').';
    s  = s / (max(abs(s)) + eps);                % swing normalised to [-1, 1]

    % map to a major-pentatonic scale over ~3 octaves so it always sounds harmonic
    scale = [0 2 4 7 9];
    notes = sort([scale-12, scale, scale+12, scale+24]);
    idx   = round((s+1)/2 * (numel(notes)-1)) + 1;
    semis = notes(min(max(idx,1),numel(notes))).';
    freq  = 220 * 2.^(semis/12);                 % base A3

    w    = max(round(0.03*fs), 1);
    freq = movmean(freq, w);                      % glide between notes (portamento)
    ph   = 2*pi*cumsum(freq)/fs;
    y    = sin(ph) + 0.5*sin(2*ph) + 0.28*sin(3*ph) + 0.16*sin(4*ph);  % harmonics

    spd  = abs([0; diff(s)]);                     % louder while swinging fast
    spd  = spd / (max(spd) + eps);
    y    = y .* (0.35 + 0.65*movmean(spd, w));

    nf   = round(0.05*fs);                        % gentle fade in / out
    env  = ones(L,1);
    env(1:nf)        = linspace(0,1,nf);
    env(end-nf+1:end) = linspace(1,0,nf);
    y    = 0.9 * (y .* env) / (max(abs(y .* env)) + eps);
end

function [C, A] = speakerIconRGBA(sz, col, on)
% speakerIconRGBA  Speaker icon; sound waves when on, a slash when muted.
    [xx, yy] = meshgrid(1:sz, 1:sz);
    x = (xx-1)/(sz-1);  y = (yy-1)/(sz-1);
    body = x >= 0.10 & x <= 0.30 & abs(y-0.5) <= 0.13;
    t    = max(min((x-0.30)/0.20, 1), 0);
    cone = x >= 0.30 & x <= 0.50 & abs(y-0.5) <= (0.13 + t*0.17);
    A = double(body | cone);
    if on
        r = hypot(x-0.50, y-0.5);
        A(x > 0.54 & abs(r-0.18) < 0.028) = 1;   % near sound wave
        A(x > 0.54 & abs(r-0.30) < 0.028) = 1;   % far sound wave
    else
        A(abs(x - y) < 0.03 & x > 0.08 & x < 0.62) = 1;   % mute slash
    end
    C = cat(3, col(1)*ones(sz), col(2)*ones(sz), col(3)*ones(sz));
end

function in = inTri(x, y, p1, p2, p3)
% point-in-triangle test (vectorised, sign method)
    d1 = (x-p2(1)).*(p1(2)-p2(2)) - (p1(1)-p2(1)).*(y-p2(2));
    d2 = (x-p3(1)).*(p2(2)-p3(2)) - (p2(1)-p3(1)).*(y-p3(2));
    d3 = (x-p1(1)).*(p3(2)-p1(2)) - (p3(1)-p1(1)).*(y-p1(2));
    hasNeg = (d1<0) | (d2<0) | (d3<0);
    hasPos = (d1>0) | (d2>0) | (d3>0);
    in = ~(hasNeg & hasPos);
end
