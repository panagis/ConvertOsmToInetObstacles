# ConvertOsmToInetObstacles

This script extracts INET/OMNeT++ obstacles from an OpenStreetMap (OSM) map.

## Description

The purpose of obstacles in INET framework is to simulate real world objects such as walls, trees, buildings and hills. 
More specifically, they are used to absorb and reflect radio waves, reducing signal quality and decreasing the chance of a successful reception.
Using this script, you are able to extract the obstacles (buildings, pavements...) of any OSM map and then use them on the INET framework.
In case you make use of the *veins_inet* project, you can set the margin variable too. Differently, please ignore this parameter and set it to 0.

## Usage

Extract INET obstacles from an OSM using the default margin of the veins_inet project.

```
./ConvertOsmToInetObstacles.sh <osm-net-filename> <osm-poly-filename> <destination-filename>
```
  
Extract INET obstacles from an OSM map using a custom margin.

```
./ConvertOsmToInetObstacles.sh <osm-net-filename> <osm-poly-filename> <destination-filename> <margin>
```

## Example

In this example, we will download an OSM map using the osmWebWizard.py tool which comes along with the [SUMO](http://sumo.dlr.de/index.html) road traffic simulator and then we will extract the INET obstacles.

### Download the map

1. Run the osmWebWizard.py.
2. Select the area that you want to download.
3. Press the Generate Scenario button.
3. Find the downloaded OSM map to the same folder from which you have run the osmWebWizard.py.

### Extract the INET obstacles from the map

1. Open the terminal.
2. Navigate to the folder which contains the ConvertOsmToInetObstacles.sh script.
3. Run the following command.
```
./ConvertOsmToInetObstacles.sh path/to/the/downloaded/map/osm.net.xml path/to/the/downloaded/map/osm.poly.xml obstacles.xml
```
4. In the current folder you will find the obstacles.xml file, which you can use to the INET project.
5. Done!

## More information

https://inet.omnetpp.org/docs/tutorials/wireless/doc/step11.html
