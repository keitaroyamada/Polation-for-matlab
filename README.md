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
pol.data = struct(...
                "reference_lat",latitude array of reference dataset,...
                "reference_lon",longitude array of reference dataset, ...
                "reference_alt",altitude array of reference dataset, ...
                "reference_data",data array of reference dataset, ...
                "target_lat",latitude array of target points,...
                "target_lon",longitude array of target points, ...
                "target_alt",altitude array of target points);

%show input dataset
%pol.plot_indata();%without mapping toolbox
pol.map_indata();%requires mapping toolbox
```
3. Set calculation options
Specify the interpolation method and its options. By performing the reprojection of reference points using the _reprojection()_ method, it is possible to assess the validity of the interpolation method and its parameters.
The supported options are as follows.
- '_method_'["interpolation"(default), "nearest"]
  Polation supports two methods.
  interplation: Interpolate by taking a weighted average of the reference dataset within the specified radius.
  nearest: Refer to the nearest reference data.
- '_weighting_power_'[0- (default: 2)]
  Weight of each data point, used exclusively in interpolation method, is defined as follows.
  $$w = d^{-p}$$
  $w$: weight, $p$: weighting power, $d$: distance between target point and data point
- '_radious_'[0- (default: 300)]
  Radius to search for interpolation.
- '_radious_unit_'["degree","kilometer"(default)]
  degree: Calculate great-circular distances based on the Haversine formula.
  kilometer: Calculate distances based on Karney (2013).
- '_lapse_rate_'[(default: 0)]
  This is an elevation correction parameter intended for the interpolation of temperature. Specify the rate of change per 100 meters. For temperature, it is -0.65°C/100m.
- '_include_zeropoint_'[false(default), true]
  Specify whether to include in the interpolation a reference that exists at the same location as the target point. If included, the weight of zero-point will use the average weight of other reference data.
  
```
pol.calc_opts = struct(...
                "method","interpolation",...
                "weighting_power",2,...
                "radious",300,...
                "radious_unit","kilometer", ...
                "lapse_rate",-0.6,...%[if data is temperature, set to -0.65]
                "include_zeropoint",false);

%check accuracy(reprojection of reference data)
pol.reprojection();
```
4. Run
Execute the interpolation. The interpolated results can be visually verified by using _plot_result()_ method or _map_result()_ method.
```
%calc
pol.run();

%show result
%pol.plot_result();%without mapping toolbox
pol.map_result(); %requires mapping toolbox
```
5. Export
Export the interpolated results to a CSV file.
```
%export
[save_name, save_path] = uiputfile()
pol.export(fullfile(save_path, save_name));
```

---
## References
- [Computer programs produced by Takeshi Nakagawa](http://polsystems.rits-palaeo.com/)
- [geographiclib](https://github.com/geographiclib/geographiclib-octave)
---
