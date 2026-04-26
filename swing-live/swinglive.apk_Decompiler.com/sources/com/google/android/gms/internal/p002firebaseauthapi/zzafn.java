package com.google.android.gms.internal.p002firebaseauthapi;

import android.util.Log;
import java.io.UnsupportedEncodingException;
import org.json.JSONException;
import org.json.JSONObject;

/* JADX INFO: loaded from: classes.dex */
public final class zzafn {
    private String zza;
    private String zzb;
    private String zzc;
    private Long zzd;
    private Long zze;
    private boolean zzf;

    public static zzafn zza(String str) throws UnsupportedEncodingException {
        try {
            zzafn zzafnVar = new zzafn();
            JSONObject jSONObject = new JSONObject(str);
            zzafnVar.zza = jSONObject.optString("iss");
            zzafnVar.zzb = jSONObject.optString("aud");
            zzafnVar.zzc = jSONObject.optString("sub");
            zzafnVar.zzd = Long.valueOf(jSONObject.optLong("iat"));
            zzafnVar.zze = Long.valueOf(jSONObject.optLong("exp"));
            zzafnVar.zzf = jSONObject.optBoolean("is_anonymous");
            return zzafnVar;
        } catch (JSONException e) {
            if (Log.isLoggable("JwtToken", 3)) {
                Log.d("JwtToken", "Failed to read JwtToken from JSONObject. ".concat(String.valueOf(e)));
            }
            throw new UnsupportedEncodingException("Failed to read JwtToken from JSONObject. ".concat(String.valueOf(e)));
        }
    }

    public final Long zzb() {
        return this.zzd;
    }

    public final Long zza() {
        return this.zze;
    }
}
