package com.google.android.gms.internal.p002firebaseauthapi;

import java.util.regex.Pattern;

/* JADX INFO: loaded from: classes.dex */
final class zzx implements zzv {
    private zzx() {
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzv
    public final zzs zza(String str) {
        return new zzu(Pattern.compile(str));
    }
}
