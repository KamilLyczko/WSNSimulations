package wsnsimulations.custom;

import inet.node.inet.AdhocHost;

module StarAdhocHost extends AdhocHost
{
    parameters:
        double positionAngle;
        int distanceToSink @unit(m);
}
