package com.google.android.gms.internal.p002firebaseauthapi;

import A0.a;
import a.AbstractC0184a;
import android.os.Parcel;
import android.os.Parcelable;
import java.util.ArrayList;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

/* JADX INFO: loaded from: classes.dex */
public final class zzafp extends a {
    public static final Parcelable.Creator<zzafp> CREATOR = new zzafs();
    private final String zza;
    private final String zzb;
    private final String zzc;

    public zzafp(String str, String str2, String str3) {
        this.zza = str;
        this.zzb = str2;
        this.zzc = str3;
    }

    public static zzaq<zzafp> zza(JSONArray jSONArray) throws JSONException {
        if (jSONArray == null || jSONArray.length() == 0) {
            return zzaq.zza(new ArrayList());
        }
        zzap zzapVarZzg = zzaq.zzg();
        for (int i4 = 0; i4 < jSONArray.length(); i4++) {
            JSONObject jSONObject = jSONArray.getJSONObject(i4);
            zzapVarZzg.zza(new zzafp(jSONObject.getString("credentialId"), jSONObject.getString("name"), jSONObject.getString("displayName")));
        }
        return zzapVarZzg.zza();
    }

    @Override // android.os.Parcelable
    public final void writeToParcel(Parcel parcel, int i4) {
        int iM0 = AbstractC0184a.m0(20293, parcel);
        AbstractC0184a.i0(parcel, 1, this.zza, false);
        AbstractC0184a.i0(parcel, 2, this.zzb, false);
        AbstractC0184a.i0(parcel, 3, this.zzc, false);
        AbstractC0184a.n0(iM0, parcel);
    }
}
