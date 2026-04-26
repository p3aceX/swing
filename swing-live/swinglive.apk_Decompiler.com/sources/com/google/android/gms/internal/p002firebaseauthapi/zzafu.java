package com.google.android.gms.internal.p002firebaseauthapi;

import G0.c;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

/* JADX INFO: loaded from: classes.dex */
public final class zzafu {
    private List<zzafr> zza;

    public zzafu() {
        this.zza = new ArrayList();
    }

    public static zzafu zza(JSONArray jSONArray) throws JSONException {
        if (jSONArray == null || jSONArray.length() == 0) {
            return new zzafu(new ArrayList());
        }
        ArrayList arrayList = new ArrayList();
        for (int i4 = 0; i4 < jSONArray.length(); i4++) {
            JSONObject jSONObject = jSONArray.getJSONObject(i4);
            arrayList.add(jSONObject == null ? new zzafr() : new zzafr(c.a(jSONObject.optString("federatedId", null)), c.a(jSONObject.optString("displayName", null)), c.a(jSONObject.optString("photoUrl", null)), c.a(jSONObject.optString("providerId", null)), null, c.a(jSONObject.optString("phoneNumber", null)), c.a(jSONObject.optString("email", null))));
        }
        return new zzafu(arrayList);
    }

    private zzafu(List<zzafr> list) {
        if (!list.isEmpty()) {
            this.zza = Collections.unmodifiableList(list);
        } else {
            this.zza = Collections.EMPTY_LIST;
        }
    }

    public final List<zzafr> zza() {
        return this.zza;
    }
}
