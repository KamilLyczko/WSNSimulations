package wsnsimulations.simulations.Sim802154;

import wsnsimulations.custom.StarSensorNode;
import inet.node.inet.SensorNode;
import inet.node.inet.StandardHost;
import inet.node.ethernet.Eth100M;

import inet.networklayer.configurator.ipv4.Ipv4NetworkConfigurator;
import inet.physicallayer.wireless.ieee802154.packetlevel.Ieee802154NarrowbandScalarRadioMedium;
import inet.visualizer.common.IntegratedVisualizer;

network Sim802154
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
        sensorType1[sensorsType1Number]: StarSensorNode {
            @display("i=misc/sensor");
            //positionAngle = uniform(0,6.28);
            positionAngle = index*parent.angleStep; //index operator - Omnet doc 19.5.6
            distanceToSink = parent.distFromSensorToSink;
            mobility.initialX = parent.gatewayX + distanceToSink*cos(positionAngle);
            mobility.initialY = parent.gatewayY + distanceToSink*sin(positionAngle);
        }
        sensorType2[sensorsType2Number]: StarSensorNode {
            @display("i=misc/sensor2");
            //positionAngle = uniform(0,6.28);
            positionAngle = (index+parent.sensorsType1Number)*parent.angleStep;
            distanceToSink = parent.distFromSensorToSink;
            mobility.initialX = parent.gatewayX + distanceToSink*cos(positionAngle);
            mobility.initialY = parent.gatewayY + distanceToSink*sin(positionAngle);
        }
        sensorType3[sensorsType3Number]: StarSensorNode {
            @display("i=misc/sensor3");
            //positionAngle = uniform(0,6.28);
            positionAngle = (index+parent.sensorsType1Number+parent.sensorsType2Number)*parent.angleStep;
            distanceToSink = parent.distFromSensorToSink;
            mobility.initialX = parent.gatewayX + distanceToSink*cos(positionAngle);
            mobility.initialY = parent.gatewayY + distanceToSink*sin(positionAngle);
        }
        gateway: SensorNode {
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
        visualizer: IntegratedVisualizer {
            @display("p=40,200");
            *.networkRouteVisualizer.displayRoutes = parent.enableVisualisation;
            *.physicalLinkVisualizer.displayLinks = parent.enableVisualisation;
        }
        radioMedium: Ieee802154NarrowbandScalarRadioMedium {
            @display("p=40,260");
        }
    connections:
        gateway.ethg++ <--> Eth100M <--> server.ethg++; //Ethernet gate



}
