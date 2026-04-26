package com.google.android.gms.internal.p002firebaseauthapi;

/* JADX INFO: loaded from: classes.dex */
public final class zzpe extends RuntimeException {
    public zzpe(String str) {
        super(str);
    }

    public static <T> T zza(zzph<T> zzphVar) {
        try {
            return zzphVar.zza();
        } catch (Exception e) {
            throw new zzpe(e);
        }
    }

    private zzpe(Throwable th) {
        super(th);
    }

    public zzpe(String str, Throwable th) {
        super(str, th);
    }
}
