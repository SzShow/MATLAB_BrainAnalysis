import SSVEP_NN.*

layer=SSVEPCNNLayer1(500, 10, 4);
validInputSize=[500, 10, 1];
checkLayer(layer, validInputSize, 'ObservationDimension', 4);