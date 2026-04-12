function y = ihom(x)
% crear 
y = x(1:end-1,:);
y = y./repmat(x(end,:),size(y,1),1);


end