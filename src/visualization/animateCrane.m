function animateCrane(X, T_s, varargin)
% ANIMATECRANE  Animate the overhead crane from a state trajectory.
%   X = [x_load, v_load, x_crane, v_crane]  (one row per time step)

    % parse inputs 
    p = inputParser;
    addParameter(p, 'CableLength', 2);
    addParameter(p, 'Speed', 1);
    addParameter(p, 'Ref', []);
    addParameter(p, 'Input', []);
    addParameter(p, 'Trail', true);
    addParameter(p, 'Record', '');
    addParameter(p, 'Title', 'Overhead crane');
    addParameter(p, 'Parent', []);
    parse(p, varargin{:});
    opt = p.Results;

    if size(X,2) ~= 4 && size(X,1) == 4   % accept 4 x N
        X = X.';
    end
    assert(size(X,2) == 4, 'X must have 4 columns: [x_load, v_load, x_crane, v_crane].');

    x_load  = X(:,1);
    v_crane = X(:,4);
    x_crane = X(:,3);
    N = size(X,1);
    L = opt.CableLength;

    % horizontal swing offset clamped so the cable never over-extends
    dx = x_load - x_crane;
    dx = max(min(dx, L*0.999), -L*0.999);
    y_load = -sqrt(L.^2 - dx.^2);
    % swing angle from vertical [deg]
    theta  = asind(dx ./ L);               

    %  axes / figure setup
    if isempty(opt.Parent)
        fig = figure('Color','w','Name','animateCrane', ...
                     'Position',[80 80 1150 680]);
        ax  = axes('Parent',fig);
    else
        ax  = opt.Parent;
        fig = ancestor(ax,'figure');
    end
    hold(ax,'on'); box(ax,'on'); grid(ax,'on');
    set(ax,'FontSize',13);
    axis(ax,'equal');

    refVec = opt.Ref(:).';
    xspan = max([max(abs([x_load; x_crane])) + 1, abs(refVec), 4]);
    xlim(ax, [-xspan, xspan]);
    ylim(ax, [-(L+0.6), 0.9]);
    xlabel(ax,'horizontal position  x  [m]','FontSize',14);
    ylabel(ax,'height  [m]','FontSize',14);
    title(ax, opt.Title,'FontSize',15);

    % rail (the gantry beam the trolley rides on)
    plot(ax, [-xspan xspan], [0 0], 'k-', 'LineWidth', 3);

    % FIXED vertical target line: where we want the load to end up
    targetLine = []; targetMark = [];
    if ~isempty(refVec)
        targetLine = plot(ax, [refVec(1) refVec(1)], ylim(ax), '--', ...
                          'Color',[0.85 0.1 0.1], 'LineWidth', 1.5);
        targetMark = plot(ax, refVec(1), -L, 'x', 'Color',[0.85 0.1 0.1], ...
                          'MarkerSize', 16, 'LineWidth', 2.5);
    end

    % load path trail
    trail = [];
    if opt.Trail
        trail = plot(ax, x_load(1), y_load(1), '-', ...
                     'Color', [0.30 0.55 0.95], 'LineWidth', 1.5);
    end

    % Create cable, trolley, load
    cable   = plot(ax, [x_crane(1) x_load(1)], [0 y_load(1)], ...
                   'k-', 'LineWidth', 2);
    trolley = rectangle('Parent',ax, 'Position', troPos(x_crane(1)), ...
                   'FaceColor', [0.30 0.30 0.30], 'Curvature', 0.2);
    load    = rectangle('Parent',ax, 'Position', loadPos(x_load(1), y_load(1)), ...
                   'FaceColor', [0.85 0.33 0.10], 'Curvature', 0.1);

    % input arrow above the trolley
    inpArrow = [];
    if ~isempty(opt.Input)
        u = opt.Input(:).';
        uscale = 0.6 / max(max(abs(u)), eps);   % scale so max arrow ~0.6 m
        inpArrow = quiver(ax, x_crane(1), 0.45, u(1)*uscale, 0, 0, ...
                          'Color',[0 0.45 0.74], 'LineWidth', 2, 'MaxHeadSize', 3);
    end

    % info readout, drawn inside a bordered box (top-left of the axes)
    txt = text(ax, 0.015, 0.97, '', 'Units','normalized', ...
               'FontName','Consolas', 'FontSize', 12, 'FontWeight','bold', ...
               'VerticalAlignment','top', 'HorizontalAlignment','left', ...
               'Color',[0.10 0.10 0.10], ...                 % dark text, fixed
               'BackgroundColor',[1 1 1], 'EdgeColor',[0.3 0.3 0.3], ...
               'LineWidth',1, 'Margin',8);

    % legend: only the target marker
    if ~isempty(targetMark)
        legend(ax, targetMark, 'target x_{load}', 'Location','northeast','FontSize',11);
    end

    % Video recorder 
    writer = [];
    if ~isempty(opt.Record)
        if endsWith(lower(opt.Record),'.mp4')
            writer = VideoWriter(opt.Record,'MPEG-4');
        else
            writer = VideoWriter(opt.Record);
        end
        writer.FrameRate = max(1, round(opt.Speed/T_s));
        open(writer);
    end

    %  animation loop
    dt = T_s / max(opt.Speed, eps);
    for k = 1:N
        set(cable,   'XData', [x_crane(k) x_load(k)], 'YData', [0 y_load(k)]);
        set(trolley, 'Position', troPos(x_crane(k)));
        set(load,    'Position', loadPos(x_load(k), y_load(k)));
        if ~isempty(trail)
            set(trail, 'XData', x_load(1:k), 'YData', y_load(1:k));
        end
        if ~isempty(targetLine)
            r = refVec(min(k, numel(refVec)));
            set(targetLine, 'XData', [r r]);     % only X moves; height fixed
            set(targetMark, 'XData', r);
        end
        if ~isempty(inpArrow)
            uk = u(min(k, numel(u)));
            set(inpArrow, 'XData', x_crane(k), 'UData', uk*uscale);
        end
        str = sprintf(['t        = %5.2f s\n' ...
                       'x_{load}  = %6.2f m\n' ...
                       'x_{crane} = %6.2f m\n' ...
                       'swing    = %6.2f m  (%5.1f deg)\n' ...
                       'v_{crane} = %6.2f m/s'], ...
                       (k-1)*T_s, x_load(k), x_crane(k), dx(k), theta(k), v_crane(k));
        if ~isempty(opt.Input)
            str = sprintf('%s\nu        = %6.2f', str, u(min(k,numel(u))));
        end
        set(txt, 'String', str);

        drawnow limitrate;
        if ~isempty(writer)
            writeVideo(writer, getframe(fig));
        else
            pause(dt);
        end
    end

    if ~isempty(writer)
        close(writer);
        fprintf('Saved animation to %s\n', opt.Record);
    end

    % helpers
    function pos = troPos(xc)
        w = 0.5; h = 0.18;
        % trolley straddles the rail
        pos = [xc - w/2, -h/2, w, h];     
    end
    function pos = loadPos(xl, yl)
        s = 0.4;
        % square load mass centered at (xl,yl)
        pos = [xl - s/2, yl - s/2, s, s]; 
    end
end
