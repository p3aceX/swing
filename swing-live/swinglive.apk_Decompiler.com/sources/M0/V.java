package M0;

import android.os.Parcel;
import android.os.Parcelable;

/* JADX INFO: loaded from: classes.dex */
public enum V implements Parcelable {
    /* JADX INFO: Fake field, exist only in values array */
    USER_VERIFICATION_REQUIRED("required"),
    /* JADX INFO: Fake field, exist only in values array */
    USER_VERIFICATION_PREFERRED("preferred"),
    /* JADX INFO: Fake field, exist only in values array */
    USER_VERIFICATION_DISCOURAGED("discouraged");

    public static final Parcelable.Creator<V> CREATOR = new D0.c(28);

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final String f981a;

    V(String str) {
        this.f981a = str;
    }

    public static V a(String str) throws U {
        for (V v : values()) {
            if (str.equals(v.f981a)) {
                return v;
            }
        }
        throw new U(com.google.crypto.tink.shaded.protobuf.S.g("User verification requirement ", str, " not supported"));
    }

    @Override // android.os.Parcelable
    public final int describeContents() {
        return 0;
    }

    @Override // java.lang.Enum
    public final String toString() {
        return this.f981a;
    }

    @Override // android.os.Parcelable
    public final void writeToParcel(Parcel parcel, int i4) {
        parcel.writeString(this.f981a);
    }
}
