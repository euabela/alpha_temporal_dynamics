clear slope
for subi = 1:39
    tmp = squeeze(mean(psds(subi,281:end,:),3));
    lm  = fitlm(foi,tmp);
    slope(subi,1) = lm.Coefficients{2,1};
end
    