package j1;

import O.O;
import a.AbstractC0184a;
import android.os.Parcel;
import android.os.Parcelable;
import android.util.Log;
import com.google.android.gms.internal.p002firebaseauthapi.zzagq;
import com.google.android.gms.internal.p002firebaseauthapi.zzxv;
import org.json.JSONException;
import org.json.JSONObject;

/* JADX INFO: loaded from: classes.dex */
public final class x extends p {
    public static final Parcelable.Creator<x> CREATOR = new O(27);

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final String f5214a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final String f5215b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final long f5216c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final zzagq f5217d;

    public x(String str, String str2, long j4, zzagq zzagqVar) {
        com.google.android.gms.common.internal.F.d(str);
        this.f5214a = str;
        this.f5215b = str2;
        this.f5216c = j4;
        com.google.android.gms.common.internal.F.h(zzagqVar, "totpInfo cannot be null.");
        this.f5217d = zzagqVar;
    }

    public static x d(JSONObject jSONObject) {
        if (!jSONObject.has("enrollmentTimestamp")) {
            throw new IllegalArgumentException("An enrollment timestamp in seconds of UTC time since Unix epoch is required to build a TotpMultiFactorInfo instance.");
        }
        long jOptLong = jSONObject.optLong("enrollmentTimestamp");
        if (jSONObject.opt("totpInfo") == null) {
            throw new IllegalArgumentException("A totpInfo is required to build a TotpMultiFactorInfo instance.");
        }
        return new x(jSONObject.optString("uid"), jSONObject.optString("displayName"), jOptLong, new zzagq());
    }

    @Override // j1.p
    public final String b() {
        return "totp";
    }

    @Override // j1.p
    public final JSONObject c() {
        JSONObject jSONObject = new JSONObject();
        try {
            jSONObject.putOpt("factorIdKey", "totp");
            jSONObject.putOpt("uid", this.f5214a);
            jSONObject.putOpt("displayName", this.f5215b);
            jSONObject.putOpt("enrollmentTimestamp", Long.valueOf(this.f5216c));
            jSONObject.putOpt("totpInfo", this.f5217d);
            return jSONObject;
        } catch (JSONException e) {
            Log.d("TotpMultiFactorInfo", "Failed to jsonify this object");
            throw new zzxv(e);
        }
    }

    @Override // android.os.Parcelable
    public final void writeToParcel(Parcel parcel, int i4) {
        int iM0 = AbstractC0184a.m0(20293, parcel);
        AbstractC0184a.i0(parcel, 1, this.f5214a, false);
        AbstractC0184a.i0(parcel, 2, this.f5215b, false);
        AbstractC0184a.o0(parcel, 3, 8);
        parcel.writeLong(this.f5216c);
        AbstractC0184a.h0(parcel, 4, this.f5217d, i4, false);
        AbstractC0184a.n0(iM0, parcel);
    }
}
