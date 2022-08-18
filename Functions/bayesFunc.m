function f = bayesFunc(x)
    global timer yFiltered yUnfiltered s
    stimTime = 7 + (2 - x.d);
    setStim(x.a1, x.f1, x.a2, x.f2, x.d, stimTime, s);    
    [yUnfiltered(timer), ~] = objective(7, timer - 1);
    yUnfiltered(timer) = -yUnfiltered(timer);
    yFiltered(timer) = kalmanSmooth(yUnfiltered(1:timer));
    f = yFiltered(timer);
    timer = timer + 1;
end