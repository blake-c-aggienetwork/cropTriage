from numpy.core import double
import numpy as np

class LocationCoordinate2D():
    latitude = 0.0
    longitude = 0.0

    def __init__(self):
        self.latitude = double(0.0)
        self.longitude = double(0.0)

    def __init__(self, latitude, longitude):
        if (-90.0 <= latitude <= 90.0) and (-90.0 <= longitude <= 90.0):
            self.latitude = double(latitude)
            self.longitude = double(longitude)
        else:
            print("Not valid coordinates")

    def __str__(self):
        return f"LocationCoordinate2D(latitude: {self.latitude} longitude: {self.longitude})"

    # returns distance to pointB in meters
    def distanceTo(self, pointB):
        lat1, lon1 = [self.latitude,self.longitude]
        lat2, lon2 = [pointB.latitude,pointB.longitude]
        radius = 6371*1000  # meters

        dlat = np.radians(lat2 - lat1)
        dlon = np.radians(lon2 - lon1)
        a = np.sin(dlat / 2) * np.sin(dlat / 2) + np.cos(np.radians(lat1)) \
            * np.cos(np.radians(lat2)) * np.sin(dlon / 2) * np.sin(dlon / 2)
        c = 2 * np.arctan2(np.sqrt(a), np.sqrt(1 - a))
        d = radius * c

        return d



coord1 = LocationCoordinate2D(50.0,30.0)
coord2 = LocationCoordinate2D(50.1,30.1)

print(coord1.distanceTo(coord2))