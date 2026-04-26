package com.google.android.gms.internal.p002firebaseauthapi;

import G0.c;
import org.json.JSONException;
import org.json.JSONObject;

/* JADX INFO: loaded from: classes.dex */
public class zzafi implements zzacq<zzafi> {
    private static final String zza = "zzafi";
    private String zzb;

    public zzafi() {
    }

    /* JADX INFO: Access modifiers changed from: private */
    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzacq
    /* JADX INFO: renamed from: zzb, reason: merged with bridge method [inline-methods] */
    public final zzafi zza(String str) throws zzaah {
        try {
            this.zzb = c.a(new JSONObject(str).optString("producerProjectNumber"));
            return this;
        } catch (NullPointerException | JSONException e) {
            throw zzahb.zza(e, zza, str);
        }
    }

    public zzafi(String str) {
        this.zzb = str;
    }

    public final String zza() {
        return this.zzb;
    }
}
