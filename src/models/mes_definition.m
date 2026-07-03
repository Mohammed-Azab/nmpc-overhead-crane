function y = mes_definition(x, u, strct)
% MES_DEFINITION  Measurement equation y = h(x,u).
%   y = mes_definition(x, u, strct) returns the measured output.
%   In day-to-day operation only the load position is measured (y = x_load).

    C = [1 0 0 0];
    y = C*x;
end
