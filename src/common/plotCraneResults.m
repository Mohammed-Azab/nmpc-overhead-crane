function plotCraneResults(res, varargin)
%
%   res fields:
%     res.t     time vector            (1 x N)
%     res.X     state trajectory       (N x 4) or (4 x N)
%                                       [x_load v_load x_crane v_crane]
%     res.u     input trajectory       (1 x N)  
%     res.ref   reference for x_load   (1 x N)  
%
%   options:
%     'Title'        figure title                     
%     'Animate'      also run animateCrane            
%     'CableLength'  passed to animateCrane           
%     'Speed'        passed to animateCrane           
%     'Save'         save the plot figure             
%     'SaveFormat'   'png' or 'svg'                  
%     'SaveDir'      output folder                    
%     'SaveAnim'     save the animation as a .gif     

    ip = inputParser;
    addParameter(ip, 'Title', 'Crane response');
    addParameter(ip, 'Animate', false);
    addParameter(ip, 'CableLength', 2);
    addParameter(ip, 'Speed', 1);
    addParameter(ip, 'Save', false);
    addParameter(ip, 'SaveFormat', 'png');
    addParameter(ip, 'SaveDir', 'results');
    addParameter(ip, 'SaveAnim', false);
    addParameter(ip, 'GifStride', 3);
    addParameter(ip, 'GifScale', 0.6);
    parse(ip, varargin{:});
    opt = ip.Results;

    X = res.X;
    if size(X,1) == 4 && size(X,2) ~= 4
        X = X.';
    end
    t = res.t(:)';
    hasU   = isfield(res, 'u')   && ~isempty(res.u);
    hasRef = isfield(res, 'ref') && ~isempty(res.ref);

    % output folder
    saveDir = char(opt.SaveDir);
    if (opt.Save || opt.SaveAnim) && ~isempty(saveDir) && ~isfolder(saveDir)
        mkdir(saveDir);
    end
    base = regexprep(char(opt.Title), '[^\w-]+', '_');   % filename-safe title

    % Figure
    fig = figure('Name', opt.Title, 'Color', 'w');
    set(fig, 'DefaultAxesFontName','Times New Roman', 'DefaultTextFontName','Times New Roman');
    try, theme(fig, 'light'); catch, end   %#ok<CTCH>

    % 1) positions
    ax1 = subplot(3,1,1);
    plot(ax1, t, X(:,1), 'LineWidth', 1.8, 'DisplayName', 'x_{load}'); hold(ax1,'on')
    plot(ax1, t, X(:,3), 'LineWidth', 1.0, 'DisplayName', 'x_{crane}');
    if hasRef
        plot(ax1, t, res.ref(:)', 'k--', 'LineWidth', 1.2, 'DisplayName', 'reference');
    end
    ylabel(ax1, 'Position [m]'); title(ax1, opt.Title);
    legend(ax1, 'show', 'Location', 'best'); lightAxes(ax1);

    % 2) velocities
    ax2 = subplot(3,1,2);
    plot(ax2, t, X(:,2), 'LineWidth', 1.6, 'DisplayName', 'v_{load}'); hold(ax2,'on')
    plot(ax2, t, X(:,4), 'LineWidth', 1.6, 'DisplayName', 'v_{crane}');
    ylabel(ax2, 'Velocity [m/s]');
    legend(ax2, 'show', 'Location', 'best'); lightAxes(ax2);

    % 3) input
    ax3 = subplot(3,1,3);
    if hasU
        stairs(ax3, t, res.u(:)', 'LineWidth', 1.4);
    end
    ylabel(ax3, 'Input u [m/s^2]'); xlabel(ax3, 'Time [s]'); lightAxes(ax3);

    % Save the figure
    if opt.Save
        fmt   = lower(char(opt.SaveFormat));
        fname = fullfile(saveDir, [base '.' fmt]);
        if strcmp(fmt, 'svg')
            exportgraphics(fig, fname, 'ContentType', 'vector');
        else
            exportgraphics(fig, fname, 'Resolution', 200);
        end
        fprintf('Saved plot to %s\n', fname);
    end

    % Animation
    if opt.Animate
        T_s  = mean(diff(t));
        args = {'CableLength', opt.CableLength, 'Speed', opt.Speed, 'Title', opt.Title, ...
                'GifStride', opt.GifStride, 'GifScale', opt.GifScale};
        if hasRef, args = [args, {'Ref', res.ref}]; end
        if hasU,   args = [args, {'Input', res.u}]; end
        if opt.SaveAnim
            args = [args, {'Record', fullfile(saveDir, [base '.gif'])}];
        end
        animateCrane(X, T_s, args{:});
    end
end

function lightAxes(ax)
% pin one axes to a light appearance
    grid(ax, 'on');
    set(ax, 'Color','w', 'XColor',[0.15 0.15 0.15], 'YColor',[0.15 0.15 0.15], ...
            'GridColor',[0.15 0.15 0.15], 'GridAlpha',0.12, 'FontName','Times New Roman');
end
