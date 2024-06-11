clear;

%make instance of polation
pol = polation();

%remove nan values
r_idx = find(~isnan(reference_data.temperature));
t_idx = find(~isnan(target_data.alt));

%load calculation data
pol.data = struct(...
                "reference_lat",reference_data.lat(r_idx),...
                "reference_lon",reference_data.lon(r_idx), ...
                "reference_alt",reference_data.alt(r_idx), ...
                "reference_data",reference_data.temperature(r_idx), ...
                "target_lat",target_data.lat(t_idx),...
                "target_lon",target_data.lon(t_idx), ...
                "target_alt",target_data.alt(t_idx));

%show indata
%pol.plot_indata(); %without mapping toolbox
pol.map_indata();%requires mapping toolbox

%set calculation options
pol.calc_opts = struct(...
                "method","interpolation",...%["interpolation", "nearest"]
                "weighting_power",2,...
                "radious",100,...
                "radious_unit","geodesic_km", ...%["euclidean_degree","haversine_km","geodesic_km"]
                "lapse_rate",-0.65,...%[if data is temperature, set to -0.65]
                "include_zeropoint",false);

%check accuracy(reprojection of reference data)
pol.reprojection();

%calc interpolated values
pol.run();

%show result
%pol.plot_result(); %without mapping toolbox
pol.map_result(); %requires mapping toolbox

%export
[save_name, save_path] = uiputfile('*.csv');
pol.export(fullfile(save_path, save_name));

