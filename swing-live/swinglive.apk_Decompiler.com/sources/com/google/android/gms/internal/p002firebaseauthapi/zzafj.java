package com.google.android.gms.internal.p002firebaseauthapi;

import G0.c;
import com.google.android.gms.common.internal.F;
import java.util.ArrayList;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

/* JADX INFO: loaded from: classes.dex */
public class zzafj implements zzacq<zzafj> {
    private static final String zza = "zzafj";
    private String zzb;
    private zzaq<zzaft> zzc;

    /* JADX INFO: Access modifiers changed from: private */
    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzacq
    /* JADX INFO: renamed from: zzc, reason: merged with bridge method [inline-methods] */
    public final zzafj zza(String str) throws zzaah {
        zzaq<zzaft> zzaqVarZza;
        try {
            JSONObject jSONObject = new JSONObject(str);
            this.zzb = c.a(jSONObject.optString("recaptchaKey"));
            if (jSONObject.has("recaptchaEnforcementState")) {
                JSONArray jSONArrayOptJSONArray = jSONObject.optJSONArray("recaptchaEnforcementState");
                if (jSONArrayOptJSONArray == null || jSONArrayOptJSONArray.length() == 0) {
                    zzaqVarZza = zzaq.zza(new ArrayList());
                } else {
                    zzap zzapVarZzg = zzaq.zzg();
                    for (int i4 = 0; i4 < jSONArrayOptJSONArray.length(); i4++) {
                        JSONObject jSONObject2 = jSONArrayOptJSONArray.getJSONObject(i4);
                        zzapVarZzg.zza(jSONObject2 == null ? zzaft.zza(null, null) : zzaft.zza(c.a(jSONObject2.optString("provider")), c.a(jSONObject2.optString("enforcementState"))));
                    }
                    zzaqVarZza = zzapVarZzg.zza();
                }
                this.zzc = zzaqVarZza;
            }
            return this;
        } catch (NullPointerException e) {
            e = e;
            throw zzahb.zza(e, zza, str);
        } catch (JSONException e4) {
            e = e4;
            throw zzahb.zza(e, zza, str);
        }
    }

    public final boolean zzb(String str) {
        F.d(str);
        zzaq<zzaft> zzaqVar = this.zzc;
        String strZza = null;
        if (zzaqVar != null && !zzaqVar.isEmpty()) {
            zzaq<zzaft> zzaqVar2 = this.zzc;
            int size = zzaqVar2.size();
            int i4 = 0;
            while (true) {
                if (i4 >= size) {
                    break;
                }
                zzaft zzaftVar = zzaqVar2.get(i4);
                i4++;
                zzaft zzaftVar2 = zzaftVar;
                String strZza2 = zzaftVar2.zza();
                String strZzb = zzaftVar2.zzb();
                if (strZza2 != null && strZzb != null && strZzb.equals(str)) {
                    strZza = zzaftVar2.zza();
                    break;
                }
            }
        }
        return strZza != null && (strZza.equals("ENFORCE") || strZza.equals("AUDIT"));
    }

    public final String zza() {
        return this.zzb;
    }
}
