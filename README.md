# cropTriage
Accompanying application for senior design team 29 for Texas A&M ECEN 403, 404 Senior Design.

# Changelog
> 2/27/2021
> - Added basic networking capabilities to swift app
> - App can now send list of coordinates to local server
> - App can now download CSV files from local server
> - These functions have been verified to work with raspberry pi zero

> 2/24/2021
> - Created Python with Flask library HTTP REST API for app to interface with
> - The REST API contains these URL paths: /state, /scan, /lidar, /home, /location
> - REST API has been tested with RESTED application from app store

> 11/21/2020
> - Added more datasets for demo
> - Added button to print marker data to console
> - Prepared application for demo

> 11/14/2020
> - Added data selection wheel for crop view
> - Added exception protection for non-existent files

> 11/11/2020
> - Added histogram for crop data

> 11/7/2020
> - Added generated data centered around TAMU golfcourse
> - Added heatmap overlay capabilities

> 11/6/2020
> - Added CSV reading and parsing to cropview

> 11/2/2020
> - Added icons for app UI
> - Changed color scheme of app a bit
> - Added libraries: Charts, CSV.swift, DTMHeatmap, fontawesome
> - Started work on CropView

> 10/27/2020
> - App launches to last page when closed
> - Drone config now has tap to place marker for faster marker placement
> - Fixed issue where flight time would not update if all markers were removed
> - fixed issue with unnessary console system output

>10/25/2020
> - Fixed bug where markers would not be saved if only 1 was present
> - Map now zooms to last marker upon load of drone view insted of user location
> - Estimated flight time label now updates based off a drone moving 25 meters/sec with 6 minutes at each stop

> 10/20/2020
> - Added map view selector and is persistant
> - Markers now have data management, they are persistent
> - Added drone path lines
> - Added remove all markers button
> - Added placeholder labels for drone flight time estimate

> 10/10/2020
> - Drone Config view has "Add Marker Button"
> - Markers placed within drone config map contain a radius, displaying scan area
> - Markers can be dragged around on map

> 10/3/2020
> - Added a swipe gesture to open side menu. Added location perms and mapview to drone config view.

> 9/27/2020
> - Added app navigation capabilities. App can swap between views for Home, Drone Config, Crop Data View, and Settings

> 9/25/2020
> - Made Xcode project files, and created readme


# Unit Test Schedule for Fall 2021

| Unit Test          | Description                                                                                   | Due Date | Completed |
|--------------------|-----------------------------------------------------------------------------------------------|----------|-----------|
| Network Ability    | App can send and recieve data through a network in general.                                   | 3/1/21   |     ✅     |
| Waypoint Send      | App send waypoint list to webserver on a LAN                                                  | 3/8/21   |     ✅     |
| CSV receieve       | App can recieve CSV data from webserver on a LAN.                                             | 3/8/21  |     ✅     |
| Tune Networking    | Appropiate features for managing data recieved from the network, and QOL features             | 3/16/21  |          |


# Unit Test Schedule for Fall 2020

| Unit Test          | Description                                                                                   | Due Date | Completed |
|--------------------|-----------------------------------------------------------------------------------------------|----------|-----------|
| App navigation     | App can navigate between each page planned for the app (2 pages)                              | 9/27/20  |    ✅     |
| Map View           | App can view local area by pulling core location data                                         | 9/29/20  |    ✅     |
| Map View Config    | User can place markers for drone scanning on map view                                         | 10/6/20  |    ✅     |
| Drone path editing | User can edit drone path to ensure obstacle avoidance                                         | 10/13/20 |    ✅     |
| Data Model         | Class for managing, saving, and reading data is done. Data is persistent between app restarts | 10/13/20 |    ✅     |
| Debug              | App is logging relevant debugging information to console for above tests                      | 10/13/20 |    ✅     |
| Crop Data View     | Crop data view page is created and has a map and placeholders for statistical info            | 10/20/20 |    ✅     |
| ML/Statistics      | Crop data can be processed by App by ML or statistics algorithm and can display that info     | 10/27/20 |    ✅     |
| Receive Crop Data  | App can receive crop data from other subsystem                                                | 11/3/20  |    ✅     |
| Data model update  | Data model is updated and tested again for persistence and usability                          | 11/10/20 |    ✅     |
| Aesthetic          | App is made more aesthetic, add prettier icons, improve color palette                         | 11/10/20 |    ✅     |
| Debug again        | Ensure new parts of the app are debugging correctly                                           | 11/10/20 |    ✅     |
| Redo All Tests     | Test all previous tests                                                                       | 11/17/20 |    ✅     |



