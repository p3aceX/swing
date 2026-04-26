package com.google.android.gms.internal.p002firebaseauthapi;

import android.content.Context;
import android.content.SharedPreferences;
import android.preference.PreferenceManager;
import java.io.IOException;

/* JADX INFO: loaded from: classes.dex */
@Deprecated
final class zzmc implements zzce {
    private final SharedPreferences.Editor zza;
    private final String zzb;

    public zzmc(Context context, String str, String str2) {
        if (str == null) {
            throw new IllegalArgumentException("keysetName cannot be null");
        }
        this.zzb = str;
        Context applicationContext = context.getApplicationContext();
        if (str2 == null) {
            this.zza = PreferenceManager.getDefaultSharedPreferences(applicationContext).edit();
        } else {
            this.zza = applicationContext.getSharedPreferences(str2, 0).edit();
        }
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzce
    public final void zza(zzty zztyVar) throws IOException {
        if (!this.zza.putString(this.zzb, zzxh.zza(zztyVar.zzj())).commit()) {
            throw new IOException("Failed to write to SharedPreferences");
        }
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzce
    public final void zza(zzvh zzvhVar) throws IOException {
        if (!this.zza.putString(this.zzb, zzxh.zza(zzvhVar.zzj())).commit()) {
            throw new IOException("Failed to write to SharedPreferences");
        }
    }
}
