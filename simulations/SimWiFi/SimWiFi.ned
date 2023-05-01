//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Lesser General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
// 
package wsnsimulations.simulations.SimWiFi;

import inet.networklayer.configurator.ipv4.Ipv4NetworkConfigurator;
import inet.physicallayer.wireless.ieee80211.packetlevel.Ieee80211ScalarRadioMedium;
import inet.visualizer.contract.IIntegratedVisualizer;

import wsnsimulations.custom.StarAdhocHost;
import inet.node.inet.AdhocHost;
import inet.node.inet.StandardHost;
import inet.node.ethernet.Eth100M;

network SimWiFi
{
    parameters:
        int sensorsTotalNumber = default(10);
        int sensorsType1Number = default(3);
        int sensorsType2Number = default(4);
        int sensorsType3Number = default(3);
        int distFromSensorToSink @unit(m) = default(100m);
        int distFromServerToSink @unit(m) = default(50m);
        double gatewayX @unit(m) = default(300m);
        double gatewayY @unit(m) = default(200m);
        double serverX @unit(m) = default(gatewayX);
        double serverY @unit(m) = default(gatewayY + distFromServerToSink);
        double angleStep = 6.28/(sensorsType1Number + sensorsType2Number + sensorsType3Number);
        bool enableVisualisation = default(true);
        @display("bgb=500,400");
    submodules:
        sensorType1[sensorsType1Number]: StarAdhocHost {
            @display("i=misc/sensor");
            //positionAngle = uniform(0,6.28);
            positionAngle = index*parent.angleStep; //index operator - Omnet doc 19.5.6
            distanceToSink = parent.distFromSensorToSink;
            mobility.initialX = parent.gatewayX + distanceToSink*cos(positionAngle);
            mobility.initialY = parent.gatewayY + distanceToSink*sin(positionAngle);
        }
        sensorType2[sensorsType2Number]: StarAdhocHost {
            @display("i=misc/sensor2");
            //positionAngle = uniform(0,6.28);
            positionAngle = (index+parent.sensorsType1Number)*parent.angleStep;
            distanceToSink = parent.distFromSensorToSink;
            mobility.initialX = parent.gatewayX + distanceToSink*cos(positionAngle);
            mobility.initialY = parent.gatewayY + distanceToSink*sin(positionAngle);
        }
        sensorType3[sensorsType3Number]: StarAdhocHost {
            @display("i=misc/sensor3");
            //positionAngle = uniform(0,6.28);
            positionAngle = (index+parent.sensorsType1Number+parent.sensorsType2Number)*parent.angleStep;
            distanceToSink = parent.distFromSensorToSink;
            mobility.initialX = parent.gatewayX + distanceToSink*cos(positionAngle);
            mobility.initialY = parent.gatewayY + distanceToSink*sin(positionAngle);
        }
        gateway: AdhocHost {
            @display("i=misc/sensorgateway");
            mobility.initialX = parent.gatewayX;
            mobility.initialY = parent.gatewayY;
            
            wlan[0].radio.displayCommunicationRange = parent.enableVisualisation;
        }
        server: StandardHost {
            @display("p=$serverX,$serverY");
        }
        configurator: Ipv4NetworkConfigurator {
            @display("p=40,140");
        }
        visualizer: <default(firstAvailableOrEmpty("IntegratedCanvasVisualizer"))> like IIntegratedVisualizer if typename != "" {
            @display("p=40,200");
            mediumVisualizer.displaySignals = parent.enableVisualisation;
            networkRouteVisualizer.displayRoutes = parent.enableVisualisation;
        }
        radioMedium: Ieee80211ScalarRadioMedium {
            @display("p=40,260");
        }
    connections:
        gateway.ethg++ <--> Eth100M <--> server.ethg++; //Ethernet gate



}