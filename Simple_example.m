clear;

%make instance of polation
pol = polation();

%load calculation data
pol.data = struct(...
                "reference_lat",ref_data.Lat,...
                "reference_lon",ref_data.Lon, ...
                "reference_alt",ref_data.Elv, ...
                "reference_data",ref_data.d18Omid, ...
                "target_lat",target_data.Lat,...
                "target_lon",target_data.Lon, ...
                "target_alt",target_data.Elv);
%show indata
%pol.plot_indata();
pol.map_indata();%requires mapping toolbox

%set calculation options
pol.calc_opts = struct(...
                "method","interpolation",...%["interpolation", "nearest"]
                "weighting_power",2,...
                "radious",3,...
                "radious_unit","degree", ...%["degree","kilometer"]
                "lapse_rate",-0.6,...%[if data is temperature, set to -0.65]
                "include_zeropoint",false);

%check accuracy(reprojection of reference data)
pol.reprojection();

%calc
pol.run();

%show result
pol.plot_result();
pol.map_result(); %requires mapping toolbox

