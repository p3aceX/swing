package com.google.android.gms.internal.auth;

/* JADX INFO: loaded from: classes.dex */
public class zzej {
    public static final /* synthetic */ int zza = 0;
    private static volatile int zzb = 100;

    public /* synthetic */ zzej(zzei zzeiVar) {
    }

    public static int zzb(int i4) {
        return (i4 >>> 1) ^ (-(i4 & 1));
    }

    public static long zzc(long j4) {
        return (j4 >>> 1) ^ (-(1 & j4));
    }
}
