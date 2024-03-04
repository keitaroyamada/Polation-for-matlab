classdef polation < handle
    %Polation for matlab

    properties (SetAccess = public, GetAccess = public)
        data;
        calc_opts;
        plot_opts;
        results;
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

        function obj = run(obj)
            if isempty(obj.data.reference_lat)||isempty(obj.data.reference_lon)||isempty(obj.data.reference_data)
                disp("Input data is empty.")
                return;
            end

            output = zeros(height(obj.data.reference_data),1);
            for t=1:height(obj.data.target_lat)

                %calc distance between points
                dist = zeros(height(obj.data.target_lat),1);
                for r=1:height(obj.data.reference_lat)
                    switch obj.calc_opts.radious_unit
                        case "degree"
                            dist(r) = sqrt((obj.data.reference_lat(r)-obj.data.target_lat(t))^2+(obj.data.reference_lon(r)-obj.data.target_lon(t))^2);
                        case "kilometer"
                        otherwise
                            return
                    end
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
                            [~,idx] = min(dist);
                        else
                            idx1 = find(dist>0);
                            [~,idx2] = min(dist(idx1));
                            idx = idx1(idx2);
                        end
    
                        %calc
                        %at 0m
                        val0m = obj.data.reference_data(idx) - (obj.data.reference_alt(idx)/100)*obj.calc_opts.lapse_rate;
                        output(t) = val0m + (obj.data.target_alt(t)/100)*obj.calc_opts.lapse_rate;

                    otherwise
                        return
                end
            end
            
            obj.results = output;
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

        function h = plot_result(obj)
            if isempty(obj.results)
                disp("Result data are empty.")
                return;
            end
            figure
            h = scatter(obj.data.target_lon,obj.data.target_lat,20,obj.results,"filled");
            title("Interpolated")
            xlabel("Longitude")
            ylabel("Latitude")
            colorbar();
            grid on
        end

    end
end