package com.google.android.gms.internal.p002firebaseauthapi;

import android.util.Log;
import java.text.ParseException;
import org.json.JSONException;
import org.json.JSONObject;

/* JADX INFO: loaded from: classes.dex */
public final class zzago extends zzagi {
    private static final String zza = "zzago";
    private String zzb;
    private String zzc;
    private int zzd;
    private String zze;
    private int zzf;
    private long zzg;

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzagi, com.google.android.gms.internal.p002firebaseauthapi.zzacq
    public final /* synthetic */ zzacq zza(String str) {
        return (zzago) zza(str);
    }

    public final int zzb() {
        return this.zzf;
    }

    public final int zzc() {
        return this.zzd;
    }

    public final long zzd() {
        return this.zzg;
    }

    public final String zze() {
        return this.zze;
    }

    public final String zzf() {
        return this.zzc;
    }

    /* JADX INFO: Access modifiers changed from: private */
    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzagi
    /* JADX INFO: renamed from: zzc, reason: merged with bridge method [inline-methods] */
    public final zzago zza(String str) throws zzaah {
        try {
            JSONObject jSONObjectOptJSONObject = new JSONObject(str).optJSONObject("totpSessionInfo");
            if (jSONObjectOptJSONObject != null) {
                this.zzc = zzah.zza(jSONObjectOptJSONObject.optString("sharedSecretKey"));
                this.zzd = jSONObjectOptJSONObject.optInt("verificationCodeLength");
                this.zze = zzah.zza(jSONObjectOptJSONObject.optString("hashingAlgorithm"));
                this.zzf = jSONObjectOptJSONObject.optInt("periodSec");
                this.zzb = zzah.zza(jSONObjectOptJSONObject.optString("sessionInfo"));
                String strOptString = jSONObjectOptJSONObject.optString("finalizeEnrollmentTime");
                try {
                    this.zzg = zzand.zza(zzand.zza(strOptString));
                    return this;
                } catch (ParseException unused) {
                    Log.e(zza, "Failed to parse timestamp: " + strOptString);
                }
            }
            return this;
        } catch (NullPointerException | JSONException e) {
            throw zzahb.zza(e, zza, str);
        }
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzagi
    public final String zza() {
        return this.zzb;
    }
}
