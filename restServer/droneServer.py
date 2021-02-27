from flask import Flask, request, jsonify, send_file, make_response
from flask_restful import Resource, Api
from enum import Enum
from numpy.core import double
import numpy as np
import os

## Network parameters
hostaddress = "0.0.0.0"
serverPort = 25565


## this class is intended to mirror the LocationCoordinate2D struct within swift MapKit
## it calculates the distance between 2 coordinates slightly different
class LocationCoordinate2D:
    latitude = 0.0
    longitude = 0.0

    def __init__(self):
        self.latitude = double(0.0)
        self.longitude = double(0.0)

    def __init__(self, latitude, longitude):
        self.latitude = double(latitude)
        self.longitude = double(longitude)

    def __str__(self):
        return f"LocationCoordinate2D(latitude: {self.latitude} longitude: {self.longitude})"

    # returns distance to pointB in meters
    def distanceTo(self, pointB):
        lat1, lon1 = [self.latitude, self.longitude]
        lat2, lon2 = [pointB.latitude, pointB.longitude]
        radius = 6371 * 1000  # meters

        dlat = np.radians(lat2 - lat1)
        dlon = np.radians(lon2 - lon1)
        a = np.sin(dlat / 2) * np.sin(dlat / 2) + np.cos(np.radians(lat1)) \
            * np.cos(np.radians(lat2)) * np.sin(dlon / 2) * np.sin(dlon / 2)
        c = 2 * np.arctan2(np.sqrt(a), np.sqrt(1 - a))
        d = radius * c

        return d


## this class is intended to control the drone, managing drone state and accessing saved files
class Drone:
    # data members
    scanList = []  # this is an array of LocationCoordinate2D for scanning
    curLocation = LocationCoordinate2D(0.0, 0.0)  # this is the current location of the drone
    homeLocation = LocationCoordinate2D(0.0,0.0)
    droneBattery = 0.99  # this represents drone battery capacity

    class State(Enum):  # this class is controlling drone state
        SETUP = 0
        WAITING = 1
        SCANNING = 2
        DOWNLOAD_READY = 3

    curState = State(0)  # it is initialized to setup

    def beginScan(self):
        return True

    # GET methods
    def getStatus(self):
        list = {"location": str(self.curLocation),
                "State": str(self.curState),
                "battery": str(self.droneBattery),
                "home": str(self.homeLocation)}
        return list

    def getScanList(self):
        # build dict scanlist
        list = {}
        for i in range(0, len(self.scanList)):
            list[str(i+1)] = f"{self.scanList[i].latitude},{self.scanList[i].longitude}"
        return list

    def getHomeLocation(self):
        return str(self.homeLocation)

    def getCurLocation(self):
        ## need to refresh current location
        return str(self.curLocation)

    # SET methods
    def setState(self, statusNum):
        self.curState = self.State(statusNum)

    def setScanList(self, list):
        self.scanList.clear()
        for key in list:
            location = list[key]
            pair = location.split(sep=',')
            self.scanList.append(LocationCoordinate2D(double(pair[0]), double(pair[1])))
        print("Set coordinates for: ")
        for coord in self.scanList:
            print(coord)

    def setHomeLocation(self):
        self.homeLocation = self.getCurLocation()

    # DELETE METHODS
    def deleteLastScan(self):
        if os.path.isfile("scandata/lastscan.csv"):
            os.remove("scandata/lastscan.csv")
            if os.path.isfile("scandata/lastscan.csv") == False:
                self.setState(3)
                return True
            else:
                return False
        else:
            return False


## these classes implement methods for the REST API
class StateAPI(Resource):

    def get(self):
        print("USER GET - droneStatus")
        list = myDrone.getStatus()
        return jsonify(list)


class ScanAPI(Resource):

    def get(self):
        print("-------- USER GET - scanList --------")
        print(myDrone.getScanList())
        return jsonify(myDrone.getScanList())

    def post(self):
        print("------- USER POST - scanList --------")
        scanList = request.json
        myDrone.setScanList(scanList)
        myDrone.setState(2)
        myDrone.beginScan()
        return {"status": "successfully received scan list... starting scan"}


class LidarDataAPI(Resource):

    def get(self):
        print("--------- USER GET - lidar ---------")
        path = "scandata/lastscan.csv"
        return send_file(path, as_attachment=True)

    def delete(self):
        print("-------- USER DELETE - lidar -------")
        if myDrone.deleteLastScan() == True:
            return make_response(jsonify({"status": "delete success"}), 400)
        else:
            return make_response(jsonify({"status": "delete failed"}), 401)


class HomeAPI(Resource):

    def get(self):
        print("---------- USER GET - home -----------")
        return make_response(jsonify({"Home Location": myDrone.getHomeLocation()}))

    def post(self):
        print("------- USER POST - home --------")
        myDrone.setHomeLocation()
        myDrone.setState(1)
        return {"status": f"set home to {myDrone.getHomeLocation()} ... drone now waiting for scan list"}


class CurrentLocationAPI(Resource):
    def get(self):
        print("--------- USER GET - Current Location ----------")
        curLocation = myDrone.curLocation
        return jsonify({"latitude": str(double(curLocation.latitude)), "longitude": str(double(curLocation.longitude))})



# required inializers for web api
app = Flask(__name__)
api = Api(app)

## adds url paths to the web api
api.add_resource(StateAPI, '/state')
api.add_resource(ScanAPI, '/scan')
api.add_resource(LidarDataAPI, '/lidar')
api.add_resource(HomeAPI, '/home')
api.add_resource(CurrentLocationAPI, '/location')

if __name__ == '__main__':
    myDrone = Drone()
    app.run(host=hostaddress, port=serverPort)
