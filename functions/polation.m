classdef polation < handle
    %Polation for matlab

    properties (SetAccess = public, GetAccess = public)
        data;
        calc_opts;
        plot_opts;
        results;
        version = 'ver. 2024 06 03';
    end

    methods(Access=public)
        function obj = polation()
            obj.data = struct(...
                "reference_lat",[],...
                "reference_lon",[], ...
                "reference_alt",[], ...
                "reference_data",[], ...
                "target_lat",[],...
                "target_lon",[], ...
                "target_alt",[]);
            obj.calc_opts = struct(...
                "method","interpolation",...%["interpolation", "nearest"]
                "weighting_power",2,...
                "radious",3,...
                "radious_unit","degree", ...%["degree","kilometer"]
                "lapse_rate",0,...%[per +100m]
                "include_zeropoint",false);
            obj.plot_opts = struct();
        end

        function [] = reprojection(obj)
            if isempty(obj.data.reference_lat)||isempty(obj.data.reference_lon)||isempty(obj.data.reference_data)
                disp("Input data is empty.")
                return;
            end

            %store
            backup_indata  = obj.data;
            backup_results = obj.results;

            obj.data.target_lat = obj.data.reference_lat;
            obj.data.target_lon = obj.data.reference_lon;
            obj.data.target_alt = obj.data.reference_alt;

            obj.run();
            if isempty(obj.results)
                return;
            end

            reprojected = obj.results;
            R = corrcoef(obj.data.reference_data, reprojected);

            %show reprojected results
            figure
            scatter(obj.data.reference_data, reprojected)
            title(strcat("Replojection(R=",num2str(R(1,2)),")"))
            xlabel("Original indata")
            ylabel("Reprojected indata")
            grid on

            %restore
            obj.data = backup_indata;
            obj.results = backup_results;
        end

        function obj = run(obj)
            if isempty(obj.data.reference_lat)||isempty(obj.data.reference_lon)||isempty(obj.data.reference_data)
                disp("Input data is empty.")
                return;
            end
            if sum(isnan(obj.data.reference_lat))>0||sum(isnan(obj.data.reference_lon))>0||sum(isnan(obj.data.reference_alt))>0||sum(isnan(obj.data.reference_data))>0
                disp("Input reference data contains NaN values. Please remove.")
                return;
            end
            if sum(isnan(obj.data.target_lat))>0||sum(isnan(obj.data.target_lon))>0||sum(isnan(obj.data.target_alt))>0
                disp("Input target data contains NaN values. Please remove.")
                return;
            end

            output = zeros(height(obj.data.target_lat),1);
            for t=1:height(obj.data.target_lat)
                %calc distance between points
                
                switch obj.calc_opts.radious_unit
                    case "euclidean_degree"
                        dist = zeros(height(obj.data.target_lat),1);
                        for r=1:height(obj.data.reference_lat)
                            dist(r) = sqrt((obj.data.reference_lat(r)-obj.data.target_lat(t))^2+(obj.data.reference_lon(r)-obj.data.target_lon(t))^2);
                        end
                    case "haversine_km"
                        dist = zeros(height(obj.data.target_lat),1);
                        for r=1:height(obj.data.reference_lat)
                            dist(r) = haversine(...
                                                obj.data.reference_lat(r),...
                                                obj.data.reference_lon(r),...
                                                obj.data.target_lat(t),...
                                                obj.data.target_lon(t));
                        end
                    case "geodesic_km"
                        dist = geoddistance(...
                                            obj.data.reference_lat,...
                                            obj.data.reference_lon,...
                                            obj.data.target_lat(t),...
                                            obj.data.target_lon(t)...
                                            )/1000;
                    otherwise
                        return
                end
                
                %calc val
                idx = [];
                switch obj.calc_opts.method
                    case "interpolation"
                        if obj.calc_opts.include_zeropoint
                            idx1 = find(and(dist<=obj.calc_opts.radious,dist>0));
                            idx0 = find(dist==0);
                            idx0 = setdiff(idx0, idx1);
                            idx = [idx1; idx0];
                            %get weight
                            w1 = 1./(dist(idx1).^obj.calc_opts.weighting_power);
                            w0 = repmat(mean(w1),numel(idx0),1);
                            w = [w1;w0];
                            w = w/sum(w);
                        else
                            idx = find(and(dist<=obj.calc_opts.radious,dist>0));
                            %get weight
                            w = 1./(dist(idx).^obj.calc_opts.weighting_power);
                            w = w/sum(w);
                        end
    
                        %calc weighted mean
                        %at 0m
                        val0m = sum((obj.data.reference_data(idx) - (obj.data.reference_alt(idx)/100)*obj.calc_opts.lapse_rate).*w);
                        output(t) = val0m + (obj.data.target_alt(t)/100)*obj.calc_opts.lapse_rate;
                        
                    case "nearest"
                        if obj.calc_opts.include_zeropoint
                            [~,idx] = min(dist, []);
                        else
                            idx1 = find(dist>0);
                            [~,idx2] = min(dist(idx1), []);
                            idx = idx1(idx2);
                        end
    
                        %calc
                        %at 0m
                        val0m = obj.data.reference_data(idx) - (obj.data.reference_alt(idx)/100)*obj.calc_opts.lapse_rate;
                        output(t) = val0m + (obj.data.target_alt(t)/100)*obj.calc_opts.lapse_rate;

                    otherwise
                        return
                end
                textprogress_p(t, height(obj.data.target_lat));
            end
            obj.results = output;
        end

        function [] = export(obj, savepath)
            T = table(obj.data.target_lat, obj.data.target_lon, obj.data.target_alt, obj.results);
            T.Properties.VariableNames = {'lat','lon','alt','interpolated'};
            writetable(T, savepath);
            disp("Exported.")
        end


        function h = plot_indata(obj)
            if isempty(obj.data.reference_lat)||isempty(obj.data.reference_lon)||isempty(obj.data.reference_data)
                disp("Input data is empty.")
                return;
            end
            figure
            h = scatter(obj.data.reference_lon,obj.data.reference_lat,20,obj.data.reference_data,"filled");
            hold on
            h = scatter(obj.data.target_lon,obj.data.target_lat,"+red");
            title("Input data")
            legend("Reference","Target")
            xlabel("Longitude")
            ylabel("Latitude")
            colorbar();
            grid on
        end

        function h = map_indata(obj)
            if isempty(obj.data.reference_lat)||isempty(obj.data.reference_lon)||isempty(obj.data.reference_data)
                disp("Input data is empty.")
                return;
            end
            figure
            geoscatter(obj.data.reference_lat,obj.data.reference_lon,20,obj.data.reference_data,"filled")
            hold on
            geoscatter(obj.data.target_lat,obj.data.target_lon,"+red");
            title("Input data")
            legend("Reference","Target")
            colorbar();
            grid on
        end

        function h = plot_result(obj)
            if isempty(obj.results)
                disp("Result data are empty.")
                return;
            end
            figure
            h = scatter(obj.data.target_lon, obj.data.target_lat, 20, obj.results,"filled");
            title("Interpolated")
            xlabel("Longitude")
            ylabel("Latitude")
            colorbar();
            grid on
        end

        function h = map_result(obj)
            if isempty(obj.results)
                disp("Result data are empty.")
                return;
            end
            figure
            geoscatter(obj.data.target_lat,obj.data.target_lon,20,obj.results,"filled");
            title("Interpolated")
            colorbar();
            grid on
        end

    end
end