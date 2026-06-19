# animateCrane

Animate the overhead crane from a state trajectory with interactive visualization.

## Syntax

```matlab
animateCrane(X, T_s)
animateCrane(X, T_s, Name=Value, ...)
```

## Description

`animateCrane` creates a real-time or recorded animation of an overhead crane system, displaying the trolley position, load swing, cable geometry, and optional reference trajectories and control inputs.

### Input Data Format

The state trajectory `X` must be an **N × 4** matrix (or **4 × N** which will be transposed):

| Column | Variable | Description |
|--------|----------|-------------|
| 1 | `x_load` | Horizontal position of the load [m] |
| 2 | `v_load` | Velocity of the load [m/s] |
| 3 | `x_crane` | Horizontal position of the trolley [m] |
| 4 | `v_crane` | Velocity of the trolley [m/s] |

- **X**: State trajectory matrix (N × 4)
- **T_s**: Sampling time / timestep [s]

## Name-Value Arguments

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| **CableLength** | double | 2 | Cable length *L* [m]. Controls the maximum swing radius and load drop height. |
| **Speed** | double | 1 | Playback speed multiplier. Values < 1 slow down, > 1 speed up. |
| **Ref** | scalar or vector | [] | Reference position(s) for the load `x_load`. Drawn as a red dashed vertical line with marker. If vector, updates per timestep. |
| **Input** | vector | [] | Control input `u(k)` to display. Shown as a blue arrow above trolley and text readout. |
| **Trail** | logical | true | If true, displays the load path history as a blue line. |
| **Record** | string | '' | Filename to save animation (e.g., `'output.mp4'` or `'output.avi'`). Empty string disables recording. |
| **Title** | string | 'Overhead crane' | Figure title. |
| **Parent** | axes object | [] | Axes handle for drawing (e.g., `uitab` axes). If empty, a new figure window is created. |

## System Geometry

The overhead crane system has the following geometry:

- **Trolley (carriage)**: Rides on a horizontal rail at height *y* = 0, positioned at `x_crane`.
- **Cable**: Rigid cable of fixed length *L* connecting trolley to load.
- **Load position**: Horizontally at `x_load`, vertically at depth:
  $$y_{\text{load}} = -\sqrt{L^2 - (x_{\text{load}} - x_{\text{crane}})^2}$$
- **Swing offset**: $\Delta x = x_{\text{load}} - x_{\text{crane}}$ (clamped to $\pm L \times 0.999$)
- **Swing angle** from vertical: $\theta = \arcsin\left(\frac{\Delta x}{L}\right)$ [degrees]

### Important Note: Vertical Bob

Because the cable length is fixed, the load **naturally rises as it swings outward** and **dips lowest when hanging straight down**. This vertical motion is correct pendulum geometry, not an animation glitch.

## Output

None. The function displays animation in a figure window and/or writes to video file if `Record` is specified.

## Examples

### Basic Animation
Display the state trajectory with default parameters:
```matlab
X = randn(100, 4);      % Example state trajectory
T_s = 0.01;             % 10 ms sampling time
animateCrane(X, T_s);
```

### With Reference Position and Input
Show the control signal and track a reference:
```matlab
X = randn(200, 4);
u = sin(linspace(0, 2*pi, 200));    % Control input signal
y_ref = 1.5;                         % Fixed reference target
T_s = 0.01;

animateCrane(X, T_s, ...
    'Ref', y_ref, ...
    'Input', u, ...
    'CableLength', 2.5);
```

### Recording to Video
Save animation as MP4 file at 2× playback speed:
```matlab
X = randn(300, 4);
T_s = 0.02;

animateCrane(X, T_s, ...
    'Record', 'crane_simulation.mp4', ...
    'Speed', 2, ...
    'Title', 'NMPC Controller Response');
```

### Embedding in Custom Figure
Draw animation into an existing axes (useful for GUI/app layouts):
```matlab
fig = uifigure('Name', 'Crane Monitor');
ax = uiaxes(fig, 'Position', [10 10 500 400]);

animateCrane(X, T_s, ...
    'Parent', ax, ...
    'Trail', true, ...
    'CableLength', 3);
```

### Variable Reference Position
Update the target position per timestep:
```matlab
X = randn(150, 4);
y_ref = linspace(-2, 2, 150);    % Reference moves over time

animateCrane(X, T_s, ...
    'Ref', y_ref, ...
    'Speed', 0.5);               % Half-speed playback
```

## Notes

- **Performance**: For large trajectories (> 1000 points), consider slowing playback with `Speed < 1` or downsampling the state trajectory.
- **Color Legend**:
  - **Black** line: cable
  - **Gray** rectangle: trolley carriage
  - **Orange** rectangle: load mass
  - **Blue** line: load path trail
  - **Red** dashed line: reference target position
  - **Blue** arrow: control input magnitude
- **Video Formats**: `.mp4` uses MPEG-4 codec; other extensions (`.avi`, `.mj2`) use native MATLAB VideoWriter defaults.
- **Axis Limits**: Automatically scaled to fit trajectory ± 1 m margin and cable length.

## See Also

- `state_definition` — Define state vector structure
- `mes_definition` — Define measurement vector structure
- `simulateCran_multi` — Run crane simulations
