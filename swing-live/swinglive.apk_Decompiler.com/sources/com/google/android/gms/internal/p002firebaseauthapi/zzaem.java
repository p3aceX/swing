package com.google.android.gms.internal.p002firebaseauthapi;

import java.util.List;
import org.json.JSONException;
import org.json.JSONObject;

/* JADX INFO: loaded from: classes.dex */
public class zzaem implements zzacq<zzaem> {
    private static final String zza = "zzaem";
    private String zzb;
    private boolean zzc;
    private String zzd;
    private boolean zze;
    private zzagn zzf = zzagn.zza();
    private List<String> zzg;

    /* JADX INFO: Access modifiers changed from: private */
    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzacq
    /* JADX INFO: renamed from: zzb, reason: merged with bridge method [inline-methods] */
    public final zzaem zza(String str) throws zzaah {
        try {
            JSONObject jSONObject = new JSONObject(str);
            this.zzb = jSONObject.optString("authUri", null);
            this.zzc = jSONObject.optBoolean("registered", false);
            this.zzd = jSONObject.optString("providerId", null);
            this.zze = jSONObject.optBoolean("forExistingProvider", false);
            if (jSONObject.has("allProviders")) {
                this.zzf = new zzagn(1, zzahb.zza(jSONObject.optJSONArray("allProviders")));
            } else {
                this.zzf = zzagn.zza();
            }
            this.zzg = zzahb.zza(jSONObject.optJSONArray("signinMethods"));
            return this;
        } catch (NullPointerException e) {
            e = e;
            throw zzahb.zza(e, zza, str);
        } catch (JSONException e4) {
            e = e4;
            throw zzahb.zza(e, zza, str);
        }
    }

    public final List<String> zza() {
        return this.zzg;
    }
}
