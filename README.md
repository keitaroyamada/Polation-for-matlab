# Polation-for-matlab
**Polation** is software capable of interpolating data over geographical spaces. This **Polation for matlab** has been restructured for Matlab. In addition to the original functionalities, Polation for matlab also allows for calculations based on distance.

**Polation**は地理空間上のデータを距離の加重平均によって内挿することができるソフトウェアです。**Polation for matlab**はMatlab用にこれを再構築したものです。Polationの機能に加えて内挿距離をkmで指定可能です。

<img src=https://github.com/keitaroyamada/Polation-for-matlab/blob/b0632346296582690a0d8dd8bc1af66a4fdaea6d/resources/project/polation.png width="300" >

---
## Install
### CUI version
1. Install geographiclib from Matlab addon. Details are [here](https://github.com/geographiclib/geographiclib-octave).
2. Download all files in this repository.
3. After unzipped, add downloaded repository to the matlab path.

---
## Requirements (test emvironments)
### CUI version and GUI version (matlab app)
- Matlab > 9.13
- [geographiclib](https://github.com/geographiclib/geographiclib-octave)
- Mapping toolbox (option for map plot)

---
## Usage
Polation for matlab is a program written in an object-oriented manner. After creating an instance, interpolation can be performed based on input data and settings. A simple usage example can be found in Simple_example.m.

1. Make Polation instance
First, it must be create Polation instance, because Rgrains is encapsulated. Creating an instance of MATLAB is simple as follows.
```
%make instance
pol = polation();
```

2. Load dataset and target points
Pass the reference data, which serves as the source for interpolation, and the target data, which represent the points of interpolation, to the instance. It is important to note that the next step cannot be executed unless both the reference and target data are inputted. The reference data and target data must be of the same length, respectively. The input dataset can be visually verified by using _plot_indata()_ method or _map_indata()_ method.

```
%load test dataset
load('test_temperature_dataset.mat');

%remove nan values
r_idx = find(~isnan(reference_data.temperature));
t_idx = find(~isnan(target_data.alt));

pol.data = struct(...
                "reference_lat",reference_data.lat(r_idx),... %latitude array of reference dataset
                "reference_lon",reference_data.lon(r_idx), ... %longitude array of reference dataset
                "reference_alt",reference_data.alt(r_idx), ... %altitude array of reference dataset
                "reference_data",reference_data.temperature(r_idx), ... %data array of reference dataset
                "target_lat",target_data.lat(t_idx),... %latitude array of target points
                "target_lon",target_data.lon(t_idx), ... %longitude array of target points
                "target_alt",target_data.alt(t_idx)); altitude array of target points

%show input dataset
%pol.plot_indata();%without mapping toolbox
pol.map_indata();%requires mapping toolbox
```
3. Set calculation options
Specify the interpolation method and its options. By performing the reprojection of reference points using the _reprojection()_ method, it is possible to assess the validity of the interpolation method and its parameters.
The supported options are as follows.
- '_**method**_' ["interpolation", "nearest"] (default: "interpolation")  
  Polation supports two methods.
  interplation: Interpolate by taking a weighted average of the reference dataset within the specified radius.
  nearest: Refer to the nearest reference data.
- '_**weighting_power**_' [0 - ∞] (default: 2)  
  Weight of each data point, used exclusively in interpolation method, is defined as follows.
  $w$: weight, $p$: weighting power, $d$: distance between target point and data point.
  $$w = d^{-p}$$
  
- '_**radious**_' [0 - ∞] (default: 100)  
  Radius to search for interpolation.
- '_**radious_unit**_' ["euclidean_degree","haversine_km","geodesic_km"] (default: "geodesic_km")
  euclidean_degree: Calculates Euclidean distances in degrees.
  haversine_km: Calculates great-circular distances based on the Haversine formula.
  geodesic_km: Calculates geodesic distances based on Karney (2013).
- '_**lapse_rate**_' [-∞ - ∞] (default: 0)  
  This is an elevation correction parameter intended for the interpolation of temperature. Specify the rate of change per 100 meters. **For temperature, it is -0.65°C/100m**.
- '_**include_zeropoint**_' [false, true] (default: false)  
  Specify whether to include in the interpolation a reference that exists at the same location as the target point. If included, the weight of zero-point will use the average weight of other reference data.
  
```
pol.calc_opts = struct(...
                "method","interpolation",... %["interpolation", "nearest"]
                "weighting_power",2,...
                "radious",100,...
                "radious_unit","geodesic_km", ... %["euclidean_degree","haversine_km","geodesic_km"]
                "lapse_rate",-0.65,... %[if data is temperature, set to -0.65]
                "include_zeropoint",false);

%check accuracy(reprojection of reference data)
pol.reprojection();
```
4. Run
Execute the interpolation. The interpolated results can be visually verified by using _**plot_result()**_ method or _**map_result()**_ method.
```
%calc interpolated values
pol.run();

%show result
%pol.plot_result();%without mapping toolbox
pol.map_result(); %requires mapping toolbox
```
5. Export
Export the interpolated results to a CSV file.
```
%export
[save_name, save_path] = uiputfile('*.csv');
pol.export(fullfile(save_path, save_name));
```

---
## References
- [Computer programs produced by Takeshi Nakagawa](http://polsystems.rits-palaeo.com/)
- [geographiclib](https://github.com/geographiclib/geographiclib-octave)
---
