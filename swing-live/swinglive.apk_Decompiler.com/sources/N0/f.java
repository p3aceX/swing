package N0;

import M0.W;
import android.os.Parcel;
import android.os.Parcelable;
import com.google.crypto.tink.shaded.protobuf.S;

/* JADX INFO: loaded from: classes.dex */
public enum f implements Parcelable {
    UNKNOWN("UNKNOWN"),
    /* JADX INFO: Fake field, exist only in values array */
    V1("U2F_V1"),
    /* JADX INFO: Fake field, exist only in values array */
    V2("U2F_V2");

    public static final Parcelable.Creator<f> CREATOR = new W(22);

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final String f1117a;

    f(String str) {
        this.f1117a = str;
    }

    public static f a(String str) throws e {
        if (str == null) {
            return UNKNOWN;
        }
        for (f fVar : values()) {
            if (str.equals(fVar.f1117a)) {
                return fVar;
            }
        }
        throw new e(S.g("Protocol version ", str, " not supported"));
    }

    @Override // android.os.Parcelable
    public final int describeContents() {
        return 0;
    }

    @Override // java.lang.Enum
    public final String toString() {
        return this.f1117a;
    }

    @Override // android.os.Parcelable
    public final void writeToParcel(Parcel parcel, int i4) {
        parcel.writeString(this.f1117a);
    }
}
