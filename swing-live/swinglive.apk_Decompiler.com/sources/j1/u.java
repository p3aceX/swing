package j1;

import O.O;
import a.AbstractC0184a;
import android.os.Parcel;
import android.os.Parcelable;
import android.util.Log;
import com.google.android.gms.internal.p002firebaseauthapi.zzxv;
import org.json.JSONException;
import org.json.JSONObject;

/* JADX INFO: loaded from: classes.dex */
public final class u extends p {
    public static final Parcelable.Creator<u> CREATOR = new O(25);

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final String f5209a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final String f5210b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final long f5211c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final String f5212d;

    public u(String str, String str2, long j4, String str3) {
        com.google.android.gms.common.internal.F.d(str);
        this.f5209a = str;
        this.f5210b = str2;
        this.f5211c = j4;
        com.google.android.gms.common.internal.F.d(str3);
        this.f5212d = str3;
    }

    public static u d(JSONObject jSONObject) {
        if (jSONObject.has("enrollmentTimestamp")) {
            return new u(jSONObject.optString("uid"), jSONObject.optString("displayName"), jSONObject.optLong("enrollmentTimestamp"), jSONObject.optString("phoneNumber"));
        }
        throw new IllegalArgumentException("An enrollment timestamp in seconds of UTC time since Unix epoch is required to build a PhoneMultiFactorInfo instance.");
    }

    @Override // j1.p
    public final String b() {
        return "phone";
    }

    @Override // j1.p
    public final JSONObject c() {
        JSONObject jSONObject = new JSONObject();
        try {
            jSONObject.putOpt("factorIdKey", "phone");
            jSONObject.putOpt("uid", this.f5209a);
            jSONObject.putOpt("displayName", this.f5210b);
            jSONObject.putOpt("enrollmentTimestamp", Long.valueOf(this.f5211c));
            jSONObject.putOpt("phoneNumber", this.f5212d);
            return jSONObject;
        } catch (JSONException e) {
            Log.d("PhoneMultiFactorInfo", "Failed to jsonify this object");
            throw new zzxv(e);
        }
    }

    @Override // android.os.Parcelable
    public final void writeToParcel(Parcel parcel, int i4) {
        int iM0 = AbstractC0184a.m0(20293, parcel);
        AbstractC0184a.i0(parcel, 1, this.f5209a, false);
        AbstractC0184a.i0(parcel, 2, this.f5210b, false);
        AbstractC0184a.o0(parcel, 3, 8);
        parcel.writeLong(this.f5211c);
        AbstractC0184a.i0(parcel, 4, this.f5212d, false);
        AbstractC0184a.n0(iM0, parcel);
    }
}
