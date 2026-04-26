package M0;

import android.os.Parcel;
import android.os.Parcelable;

/* JADX INFO: loaded from: classes.dex */
public enum I implements Parcelable {
    /* JADX INFO: Fake field, exist only in values array */
    RESIDENT_KEY_DISCOURAGED("discouraged"),
    /* JADX INFO: Fake field, exist only in values array */
    RESIDENT_KEY_PREFERRED("preferred"),
    /* JADX INFO: Fake field, exist only in values array */
    RESIDENT_KEY_REQUIRED("required");

    public static final Parcelable.Creator<I> CREATOR = new D0.c(24);

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final String f966a;

    I(String str) {
        this.f966a = str;
    }

    public static I a(String str) {
        for (I i4 : values()) {
            if (str.equals(i4.f966a)) {
                return i4;
            }
        }
        throw new H(com.google.crypto.tink.shaded.protobuf.S.g("Resident key requirement ", str, " not supported"));
    }

    @Override // android.os.Parcelable
    public final int describeContents() {
        return 0;
    }

    @Override // java.lang.Enum
    public final String toString() {
        return this.f966a;
    }

    @Override // android.os.Parcelable
    public final void writeToParcel(Parcel parcel, int i4) {
        parcel.writeString(this.f966a);
    }
}
