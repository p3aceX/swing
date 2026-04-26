package com.google.android.gms.internal.p002firebaseauthapi;

import A0.a;
import G0.c;
import a.AbstractC0184a;
import android.os.Parcel;
import android.os.Parcelable;
import android.util.Log;
import com.google.android.gms.common.internal.F;
import org.json.JSONException;
import org.json.JSONObject;

/* JADX INFO: loaded from: classes.dex */
public class zzafm extends a implements zzacq<zzafm> {
    public static final Parcelable.Creator<zzafm> CREATOR = new zzafl();
    private static final String zza = "zzafm";
    private String zzb;
    private String zzc;
    private Long zzd;
    private String zze;
    private Long zzf;

    public zzafm() {
        this.zzf = Long.valueOf(System.currentTimeMillis());
    }

    /* JADX INFO: Access modifiers changed from: private */
    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzacq
    /* JADX INFO: renamed from: zzd, reason: merged with bridge method [inline-methods] */
    public final zzafm zza(String str) throws zzaah {
        try {
            JSONObject jSONObject = new JSONObject(str);
            this.zzb = c.a(jSONObject.optString("refresh_token"));
            this.zzc = c.a(jSONObject.optString("access_token"));
            this.zzd = Long.valueOf(jSONObject.optLong("expires_in", 0L));
            this.zze = c.a(jSONObject.optString("token_type"));
            this.zzf = Long.valueOf(System.currentTimeMillis());
            return this;
        } catch (NullPointerException | JSONException e) {
            throw zzahb.zza(e, zza, str);
        }
    }

    @Override // android.os.Parcelable
    public void writeToParcel(Parcel parcel, int i4) {
        int iM0 = AbstractC0184a.m0(20293, parcel);
        AbstractC0184a.i0(parcel, 2, this.zzb, false);
        AbstractC0184a.i0(parcel, 3, this.zzc, false);
        AbstractC0184a.g0(parcel, 4, Long.valueOf(zza()));
        AbstractC0184a.i0(parcel, 5, this.zze, false);
        Long l2 = this.zzf;
        l2.getClass();
        AbstractC0184a.g0(parcel, 6, l2);
        AbstractC0184a.n0(iM0, parcel);
    }

    public final long zza() {
        Long l2 = this.zzd;
        if (l2 == null) {
            return 0L;
        }
        return l2.longValue();
    }

    public final long zzb() {
        return this.zzf.longValue();
    }

    public final String zzc() {
        return this.zzc;
    }

    public final String zze() {
        return this.zze;
    }

    public final String zzf() {
        JSONObject jSONObject = new JSONObject();
        try {
            jSONObject.put("refresh_token", this.zzb);
            jSONObject.put("access_token", this.zzc);
            jSONObject.put("expires_in", this.zzd);
            jSONObject.put("token_type", this.zze);
            jSONObject.put("issued_at", this.zzf);
            return jSONObject.toString();
        } catch (JSONException e) {
            Log.d(zza, "Failed to convert GetTokenResponse to JSON");
            throw new zzxv(e);
        }
    }

    public final boolean zzg() {
        return System.currentTimeMillis() + 300000 < (this.zzd.longValue() * 1000) + this.zzf.longValue();
    }

    public static zzafm zzb(String str) {
        try {
            JSONObject jSONObject = new JSONObject(str);
            zzafm zzafmVar = new zzafm();
            zzafmVar.zzb = jSONObject.optString("refresh_token", null);
            zzafmVar.zzc = jSONObject.optString("access_token", null);
            zzafmVar.zzd = Long.valueOf(jSONObject.optLong("expires_in"));
            zzafmVar.zze = jSONObject.optString("token_type", null);
            zzafmVar.zzf = Long.valueOf(jSONObject.optLong("issued_at"));
            return zzafmVar;
        } catch (JSONException e) {
            Log.d(zza, "Failed to read GetTokenResponse from JSONObject");
            throw new zzxv(e);
        }
    }

    public final void zzc(String str) {
        F.d(str);
        this.zzb = str;
    }

    public zzafm(String str, String str2, Long l2, String str3, Long l4) {
        this.zzb = str;
        this.zzc = str2;
        this.zzd = l2;
        this.zze = str3;
        this.zzf = l4;
    }

    public final String zzd() {
        return this.zzb;
    }

    public zzafm(String str, String str2, Long l2, String str3) {
        this(str, str2, l2, str3, Long.valueOf(System.currentTimeMillis()));
    }
}
