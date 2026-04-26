package com.google.android.gms.internal.p002firebaseauthapi;

import C0.a;
import com.google.android.gms.common.internal.F;
import j1.C0457b;
import j1.C0459d;
import org.json.JSONException;
import org.json.JSONObject;

/* JADX INFO: loaded from: classes.dex */
public class zzaeo implements zzacr {
    private static final String zza = "zzaeo";
    private static final a zzb = new a(zza, new String[0]);
    private final String zzc;
    private final String zzd;
    private final String zze;
    private final String zzf;

    public zzaeo(C0459d c0459d, String str, String str2) {
        String str3 = c0459d.f5193a;
        F.d(str3);
        this.zzc = str3;
        String str4 = c0459d.f5195c;
        F.d(str4);
        this.zzd = str4;
        this.zze = str;
        this.zzf = str2;
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzacr
    public final String zza() throws JSONException {
        C0457b c0457b;
        String str = this.zzd;
        int i4 = C0457b.f5190c;
        F.d(str);
        try {
            c0457b = new C0457b(str);
        } catch (IllegalArgumentException unused) {
            c0457b = null;
        }
        String str2 = c0457b != null ? c0457b.f5191a : null;
        String str3 = c0457b != null ? c0457b.f5192b : null;
        JSONObject jSONObject = new JSONObject();
        jSONObject.put("email", this.zzc);
        if (str2 != null) {
            jSONObject.put("oobCode", str2);
        }
        if (str3 != null) {
            jSONObject.put("tenantId", str3);
        }
        String str4 = this.zze;
        if (str4 != null) {
            jSONObject.put("idToken", str4);
        }
        String str5 = this.zzf;
        if (str5 != null) {
            zzahb.zza(jSONObject, "captchaResp", str5);
        } else {
            zzahb.zza(jSONObject);
        }
        return jSONObject.toString();
    }
}
