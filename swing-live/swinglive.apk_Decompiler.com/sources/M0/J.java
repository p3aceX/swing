package M0;

import android.os.Parcel;
import android.os.Parcelable;

/* JADX INFO: loaded from: classes.dex */
public enum J implements Parcelable {
    /* JADX INFO: Fake field, exist only in values array */
    PRESENT("present"),
    /* JADX INFO: Fake field, exist only in values array */
    SUPPORTED("supported"),
    /* JADX INFO: Fake field, exist only in values array */
    NOT_SUPPORTED("not-supported");

    public static final Parcelable.Creator<J> CREATOR = new D0.c(25);

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final String f968a;

    J(String str) {
        this.f968a = str;
    }

    public static J a(String str) throws K {
        for (J j4 : values()) {
            if (str.equals(j4.f968a)) {
                return j4;
            }
        }
        throw new K(com.google.crypto.tink.shaded.protobuf.S.g("TokenBindingStatus ", str, " not supported"));
    }

    @Override // android.os.Parcelable
    public final int describeContents() {
        return 0;
    }

    @Override // java.lang.Enum
    public final String toString() {
        return this.f968a;
    }

    @Override // android.os.Parcelable
    public final void writeToParcel(Parcel parcel, int i4) {
        parcel.writeString(this.f968a);
    }
}
