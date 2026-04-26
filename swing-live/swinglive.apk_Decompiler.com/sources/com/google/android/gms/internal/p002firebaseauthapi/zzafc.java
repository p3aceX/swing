package com.google.android.gms.internal.p002firebaseauthapi;

import G0.c;
import java.util.ArrayList;
import java.util.List;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

/* JADX INFO: loaded from: classes.dex */
public class zzafc implements zzacq<zzafc> {
    private static final String zza = "zzafc";
    private zzafe zzb;

    /* JADX INFO: Access modifiers changed from: private */
    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzacq
    /* JADX INFO: renamed from: zzb, reason: merged with bridge method [inline-methods] */
    public final zzafc zza(String str) throws zzaah {
        zzafe zzafeVar;
        int i4;
        zzafb zzafbVar;
        try {
            JSONObject jSONObject = new JSONObject(str);
            if (jSONObject.has("users")) {
                JSONArray jSONArrayOptJSONArray = jSONObject.optJSONArray("users");
                if (jSONArrayOptJSONArray == null || jSONArrayOptJSONArray.length() == 0) {
                    zzafeVar = new zzafe(new ArrayList());
                } else {
                    ArrayList arrayList = new ArrayList(jSONArrayOptJSONArray.length());
                    boolean z4 = false;
                    int i5 = 0;
                    while (i5 < jSONArrayOptJSONArray.length()) {
                        JSONObject jSONObject2 = jSONArrayOptJSONArray.getJSONObject(i5);
                        if (jSONObject2 == null) {
                            zzafbVar = new zzafb();
                            i4 = i5;
                        } else {
                            i4 = i5;
                            zzafbVar = new zzafb(c.a(jSONObject2.optString("localId", null)), c.a(jSONObject2.optString("email", null)), jSONObject2.optBoolean("emailVerified", z4), c.a(jSONObject2.optString("displayName", null)), c.a(jSONObject2.optString("photoUrl", null)), zzafu.zza(jSONObject2.optJSONArray("providerUserInfo")), c.a(jSONObject2.optString("rawPassword", null)), c.a(jSONObject2.optString("phoneNumber", null)), jSONObject2.optLong("createdAt", 0L), jSONObject2.optLong("lastLoginAt", 0L), false, null, zzafq.zza(jSONObject2.optJSONArray("mfaInfo")), zzafp.zza(jSONObject2.optJSONArray("passkeyInfo")));
                        }
                        arrayList.add(zzafbVar);
                        i5 = i4 + 1;
                        z4 = false;
                    }
                    zzafeVar = new zzafe(arrayList);
                }
            } else {
                zzafeVar = new zzafe();
            }
            this.zzb = zzafeVar;
            return this;
        } catch (NullPointerException e) {
            e = e;
            throw zzahb.zza(e, zza, str);
        } catch (JSONException e4) {
            e = e4;
            throw zzahb.zza(e, zza, str);
        }
    }

    public final List<zzafb> zza() {
        return this.zzb.zza();
    }
}
