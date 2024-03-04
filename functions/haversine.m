function d = haversine(lat1, lon1, lat2, lon2)

    % radious of earth (km)
    R = 6371;

    % convert
    lat1 = deg2rad(lat1);
    lon1 = deg2rad(lon1);
    lat2 = deg2rad(lat2);
    lon2 = deg2rad(lon2);

    % diff
    deltaLat = lat2 - lat1;
    deltaLon = lon2 - lon1;

    % calc
    a = sin(deltaLat/2)^2 + cos(lat1) * cos(lat2) * sin(deltaLon/2)^2;
    c = 2 * atan2(sqrt(a), sqrt(1-a));

    % distance
    d = R * c;

end