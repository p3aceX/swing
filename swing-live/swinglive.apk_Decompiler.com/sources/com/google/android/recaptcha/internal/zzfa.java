package com.google.android.recaptcha.internal;

import android.os.Build;
import java.util.LinkedHashMap;
import java.util.Map;
import w3.c;
import x3.s;

/* JADX INFO: loaded from: classes.dex */
public final class zzfa {
    public static final zzfa zza = new zzfa();

    private zzfa() {
    }

    public static final Map zza() {
        c[] cVarArr = {new c(-4, zzl.zzz), new c(-12, zzl.zzA), new c(-6, zzl.zzv), new c(-11, zzl.zzx), new c(-13, zzl.zzB), new c(-14, zzl.zzC), new c(-2, zzl.zzw), new c(-7, zzl.zzD), new c(-5, zzl.zzE), new c(-9, zzl.zzF), new c(-8, zzl.zzP), new c(-15, zzl.zzy), new c(-1, zzl.zzG), new c(-3, zzl.zzI), new c(-10, zzl.zzJ)};
        LinkedHashMap linkedHashMap = new LinkedHashMap(s.c0(15));
        s.e0(linkedHashMap, cVarArr);
        int i4 = Build.VERSION.SDK_INT;
        if (i4 >= 26) {
            linkedHashMap.put(-16, zzl.zzH);
        }
        if (i4 >= 27) {
            linkedHashMap.put(1, zzl.zzL);
            linkedHashMap.put(2, zzl.zzM);
            linkedHashMap.put(0, zzl.zzN);
            linkedHashMap.put(3, zzl.zzO);
        }
        if (i4 >= 29) {
            linkedHashMap.put(4, zzl.zzK);
        }
        return linkedHashMap;
    }
}
