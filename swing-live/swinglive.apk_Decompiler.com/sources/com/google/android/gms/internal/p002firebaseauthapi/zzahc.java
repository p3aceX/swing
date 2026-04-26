package com.google.android.gms.internal.p002firebaseauthapi;

import G0.c;
import org.json.JSONException;
import org.json.JSONObject;

/* JADX INFO: loaded from: classes.dex */
public class zzahc implements zzacq<zzahc> {
    private static final String zza = "zzahc";
    private String zzb;
    private String zzc;

    /* JADX INFO: Access modifiers changed from: private */
    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzacq
    /* JADX INFO: renamed from: zzb, reason: merged with bridge method [inline-methods] */
    public final zzahc zza(String str) throws zzaah {
        try {
            JSONObject jSONObject = new JSONObject(str);
            this.zzb = c.a(jSONObject.optString("idToken", null));
            this.zzc = c.a(jSONObject.optString("refreshToken", null));
            return this;
        } catch (NullPointerException | JSONException e) {
            throw zzahb.zza(e, zza, str);
        }
    }

    public final String zza() {
        return this.zzb;
    }

    public final String zzb() {
        return this.zzc;
    }
}
