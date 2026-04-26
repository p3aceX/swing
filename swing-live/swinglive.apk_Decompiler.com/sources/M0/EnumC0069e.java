package M0;

import android.os.Parcel;
import android.os.Parcelable;

/* JADX INFO: renamed from: M0.e, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public enum EnumC0069e implements Parcelable {
    /* JADX INFO: Fake field, exist only in values array */
    NONE("none"),
    /* JADX INFO: Fake field, exist only in values array */
    INDIRECT("indirect"),
    /* JADX INFO: Fake field, exist only in values array */
    DIRECT("direct");

    public static final Parcelable.Creator<EnumC0069e> CREATOR = new W(0);

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final String f997a;

    EnumC0069e(String str) {
        this.f997a = str;
    }

    public static EnumC0069e a(String str) throws C0068d {
        for (EnumC0069e enumC0069e : values()) {
            if (str.equals(enumC0069e.f997a)) {
                return enumC0069e;
            }
        }
        throw new C0068d(com.google.crypto.tink.shaded.protobuf.S.g("Attestation conveyance preference ", str, " not supported"));
    }

    @Override // android.os.Parcelable
    public final int describeContents() {
        return 0;
    }

    @Override // java.lang.Enum
    public final String toString() {
        return this.f997a;
    }

    @Override // android.os.Parcelable
    public final void writeToParcel(Parcel parcel, int i4) {
        parcel.writeString(this.f997a);
    }
}
