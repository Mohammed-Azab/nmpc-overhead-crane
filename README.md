# MPC Crane Project — Bringing the Crane Under Control

Skeleton MATLAB repository for the Model Predictive Control final project. All
files are empty stubs (signatures, headers and task placeholders only) — no
logic is implemented yet.

## Required toolboxes

- Symbolic Math Toolbox
- Control System Toolbox
- Model Predictive Control Toolbox

## Structure

```
MPC_Crane_Project/
├── main.m                              % entry script: params + run tasks
├── tasks/
│   ├── task1_approximate_nonlinearity.m  % RBF approximation of input slip
│   ├── task2_nmpc.m                       % NMPC design and simulation
│   └── task3_observer_ekf.m              % continuous-discrete EKF observer
├── functions/
│   ├── predictRBF_craneTime.m            % effective acceleration with slip
│   ├── state_definition.m                % x_dot = f(x,u)
│   ├── mes_definition.m                  % y = h(x,u)
│   ├── jacobianSys.m                     % [A,B] = df/dx, df/du
│   └── discreteF.m                       % one-step ode45 propagation
├── provided/                            % course-supplied helpers (stubs)
│   ├── simulateCran_multi.m
│   ├── initializeCran.m
│   └── responseCran.m
└── results/                             % output figures/data (kept empty)
```

## Tasks

1. **Approximate the non-linearity** — average repeated impulse-response
   measurements, derive accelerations from velocities, fit a Gaussian RBF
   network, build and validate the slip function.
2. **Crane with NMPC** — analyze controllability/observability/stability,
   define the non-linear model/measurement/Jacobian, set up `nlmpc()` with
   constraints, simulate a setpoint change and check real-time capability.
3. **Implement an observer** — add a continuous-discrete EKF, compare against
   the "real" crane via `responseCran`, and re-check real-time capability.

## Notes

- Files under `provided/` are placeholders for course-supplied functions;
  replace them with the originals.
- Fallback non-linearity if Task 1 is incomplete:
  `g(u) = (20/pi)*atan((pi/20)*u)`, `dg/du = ((pi^2*u^2)/400 + 1)^(-1)`.
```
