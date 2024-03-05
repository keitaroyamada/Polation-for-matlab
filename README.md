# Polation-for-matlab
**Polation** is software capable of interpolating data over geographical spaces. This **Polation for matlab** has been restructured for Matlab. In addition to the original functionalities, Polation for matlab also allows for calculations based on distance.

**Polation**は地理空間上のデータを距離の加重平均によって内挿することができるソフトウェアです。**Polation for matlab**はMatlab用にこれを再構築したものです。Polationの機能に加えて内挿距離をkmで指定可能です。

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
```
pol.calc_opts = struct(...
                "method","interpolation",...%["interpolation", "nearest"]
                "weighting_power",2,...
                "radious",300,...
                "radious_unit","kilometer", ...%["degree","kilometer"]
                "lapse_rate",-0.6,...%[if data is temperature, set to -0.65]
                "include_zeropoint",false);

%check accuracy(reprojection of reference data)
pol.reprojection();
```
4. Run
```
%calc
pol.run();

%show result
%pol.plot_result();%without mapping toolbox
pol.map_result(); %requires mapping toolbox
```
5. Export
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
