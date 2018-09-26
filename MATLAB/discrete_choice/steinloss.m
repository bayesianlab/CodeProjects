function [ loss ] = steinloss( truth, estimated)
itruth = inv(truth);
r0ir = estimated*itruth;
loss = trace(r0ir) - logdet(r0ir) - size(truth,1);
end

