package com.google.android.gms.internal.p002firebaseauthapi;

import android.text.TextUtils;
import android.util.Log;
import com.google.android.gms.common.internal.F;
import java.text.ParseException;
import java.util.ArrayList;
import java.util.List;
import org.json.JSONArray;
import org.json.JSONObject;

/* JADX INFO: loaded from: classes.dex */
public final class zzafq {
    private final String zza;
    private final String zzb;
    private final String zzc;
    private final long zzd;
    private final zzagq zze;
    private String zzf;

    private zzafq(String str, String str2, String str3, long j4, zzagq zzagqVar) {
        if (!TextUtils.isEmpty(str) && zzagqVar != null) {
            Log.e("MfaInfo", "Cannot have both MFA phone_info and totp_info");
            throw new IllegalArgumentException("Cannot have both MFA phone_info and totp_info");
        }
        this.zza = str;
        F.d(str2);
        this.zzb = str2;
        this.zzc = str3;
        this.zzd = j4;
        this.zze = zzagqVar;
    }

    private static long zza(String str) {
        try {
            return zzand.zza(zzand.zza(str));
        } catch (ParseException e) {
            Log.w("MfaInfo", "Could not parse timestamp as ISOString. Invalid ISOString \"" + str + "\"", e);
            return 0L;
        }
    }

    public final zzagq zzb() {
        return this.zze;
    }

    public final String zzc() {
        return this.zzc;
    }

    public final String zzd() {
        return this.zzb;
    }

    public final String zze() {
        return this.zza;
    }

    public final long zza() {
        return this.zzd;
    }

    public static zzafq zza(JSONObject jSONObject) {
        zzafq zzafqVar = new zzafq(jSONObject.optString("phoneInfo", null), jSONObject.optString("mfaEnrollmentId", null), jSONObject.optString("displayName", null), zza(jSONObject.optString("enrolledAt", "")), jSONObject.opt("totpInfo") != null ? new zzagq() : null);
        zzafqVar.zzf = jSONObject.optString("unobfuscatedPhoneInfo");
        return zzafqVar;
    }

    public static List<zzafq> zza(JSONArray jSONArray) {
        if (jSONArray != null && jSONArray.length() != 0) {
            ArrayList arrayList = new ArrayList();
            for (int i4 = 0; i4 < jSONArray.length(); i4++) {
                arrayList.add(zza(jSONArray.getJSONObject(i4)));
            }
            return arrayList;
        }
        return new ArrayList();
    }
}
