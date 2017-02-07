function[val] = bigF2 (t, yNp1, yN, fnq, h)
delY = yNp1 - yN;
fnqVal = -h*.5*(fnq(t(1), yN(1,:)) + fnq(t(2), yNp1));
val = delY' + fnqVal;
end