% Set the stimulator weights
function setStim(w1, f1, w2, f2, t1, t2, s)
w1 = uint32(round(255 * w1 / 2));
f1 = uint32(round(255 * f1 / 30));
w2 = uint32(round(255 * w2 / 2));
f2 = uint32(round(255 * f2 / 30));
f1 = bitshift(f1, 8);
w2 = bitshift(w2, 16);
f2 = bitshift(f2, 24);
send1 = bitor(w1, f1);
send1 = bitor(send1,w2);
send1 = bitor(send1,f2);
t1 = uint32(round(65535 * t1 / 10));
t2 = uint32(round(65535 * t2 / 10));
t2 = bitshift(t2,16);
send2 = bitor(t1, t2);
writeline(s, num2str(send1));
writeline(s, num2str(send2));
end