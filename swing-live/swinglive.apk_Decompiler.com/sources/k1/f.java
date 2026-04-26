package k1;

import a.AbstractC0184a;
import android.os.Parcel;
import android.os.Parcelable;
import org.json.JSONException;
import org.json.JSONObject;

/* JADX INFO: loaded from: classes.dex */
public final class f implements A0.c {
    public static final Parcelable.Creator<f> CREATOR = new C0511b(2);

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final long f5524a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final long f5525b;

    public f(long j4, long j5) {
        this.f5524a = j4;
        this.f5525b = j5;
    }

    public static f a(JSONObject jSONObject) {
        if (jSONObject == null) {
            return null;
        }
        try {
            return new f(jSONObject.getLong("lastSignInTimestamp"), jSONObject.getLong("creationTimestamp"));
        } catch (JSONException unused) {
            return null;
        }
    }

    @Override // android.os.Parcelable
    public final int describeContents() {
        return 0;
    }

    @Override // android.os.Parcelable
    public final void writeToParcel(Parcel parcel, int i4) {
        int iM0 = AbstractC0184a.m0(20293, parcel);
        AbstractC0184a.o0(parcel, 1, 8);
        parcel.writeLong(this.f5524a);
        AbstractC0184a.o0(parcel, 2, 8);
        parcel.writeLong(this.f5525b);
        AbstractC0184a.n0(iM0, parcel);
    }
}
