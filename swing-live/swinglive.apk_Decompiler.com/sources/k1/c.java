package k1;

import a.AbstractC0184a;
import android.net.Uri;
import android.os.Parcel;
import android.os.Parcelable;
import android.text.TextUtils;
import android.util.Log;
import com.google.android.gms.internal.p002firebaseauthapi.zzxv;
import j1.z;
import org.json.JSONException;
import org.json.JSONObject;

/* JADX INFO: loaded from: classes.dex */
public final class c extends A0.a implements z {
    public static final Parcelable.Creator<c> CREATOR = new C0511b(0);

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public String f5505a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public String f5506b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public String f5507c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public String f5508d;
    public String e;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public String f5509f;

    /* JADX INFO: renamed from: m, reason: collision with root package name */
    public boolean f5510m;

    /* JADX INFO: renamed from: n, reason: collision with root package name */
    public String f5511n;

    public c(String str, String str2, String str3, String str4, String str5, String str6, boolean z4, String str7) {
        this.f5505a = str;
        this.f5506b = str2;
        this.e = str3;
        this.f5509f = str4;
        this.f5507c = str5;
        this.f5508d = str6;
        if (!TextUtils.isEmpty(str6)) {
            Uri.parse(str6);
        }
        this.f5510m = z4;
        this.f5511n = str7;
    }

    public static c b(String str) {
        try {
            JSONObject jSONObject = new JSONObject(str);
            return new c(jSONObject.optString("userId"), jSONObject.optString("providerId"), jSONObject.optString("email"), jSONObject.optString("phoneNumber"), jSONObject.optString("displayName"), jSONObject.optString("photoUrl"), jSONObject.optBoolean("isEmailVerified"), jSONObject.optString("rawUserInfo"));
        } catch (JSONException e) {
            Log.d("DefaultAuthUserInfo", "Failed to unpack UserInfo from JSON");
            throw new zzxv(e);
        }
    }

    @Override // j1.z
    public final String a() {
        return this.f5506b;
    }

    public final String c() {
        JSONObject jSONObject = new JSONObject();
        try {
            jSONObject.putOpt("userId", this.f5505a);
            jSONObject.putOpt("providerId", this.f5506b);
            jSONObject.putOpt("displayName", this.f5507c);
            jSONObject.putOpt("photoUrl", this.f5508d);
            jSONObject.putOpt("email", this.e);
            jSONObject.putOpt("phoneNumber", this.f5509f);
            jSONObject.putOpt("isEmailVerified", Boolean.valueOf(this.f5510m));
            jSONObject.putOpt("rawUserInfo", this.f5511n);
            return jSONObject.toString();
        } catch (JSONException e) {
            Log.d("DefaultAuthUserInfo", "Failed to jsonify this object");
            throw new zzxv(e);
        }
    }

    @Override // android.os.Parcelable
    public final void writeToParcel(Parcel parcel, int i4) {
        int iM0 = AbstractC0184a.m0(20293, parcel);
        AbstractC0184a.i0(parcel, 1, this.f5505a, false);
        AbstractC0184a.i0(parcel, 2, this.f5506b, false);
        AbstractC0184a.i0(parcel, 3, this.f5507c, false);
        AbstractC0184a.i0(parcel, 4, this.f5508d, false);
        AbstractC0184a.i0(parcel, 5, this.e, false);
        AbstractC0184a.i0(parcel, 6, this.f5509f, false);
        AbstractC0184a.o0(parcel, 7, 4);
        parcel.writeInt(this.f5510m ? 1 : 0);
        AbstractC0184a.i0(parcel, 8, this.f5511n, false);
        AbstractC0184a.n0(iM0, parcel);
    }
}
