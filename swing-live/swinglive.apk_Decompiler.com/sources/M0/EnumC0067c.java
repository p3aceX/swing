package M0;

import android.os.Parcel;
import android.os.Parcelable;

/* JADX INFO: renamed from: M0.c, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public enum EnumC0067c implements Parcelable {
    /* JADX INFO: Fake field, exist only in values array */
    PLATFORM("platform"),
    /* JADX INFO: Fake field, exist only in values array */
    CROSS_PLATFORM("cross-platform");

    public static final Parcelable.Creator<EnumC0067c> CREATOR = new D0.c(9);

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final String f994a;

    EnumC0067c(String str) {
        this.f994a = str;
    }

    public static EnumC0067c a(String str) {
        for (EnumC0067c enumC0067c : values()) {
            if (str.equals(enumC0067c.f994a)) {
                return enumC0067c;
            }
        }
        throw new C0066b(com.google.crypto.tink.shaded.protobuf.S.g("Attachment ", str, " not supported"));
    }

    @Override // android.os.Parcelable
    public final int describeContents() {
        return 0;
    }

    @Override // java.lang.Enum
    public final String toString() {
        return this.f994a;
    }

    @Override // android.os.Parcelable
    public final void writeToParcel(Parcel parcel, int i4) {
        parcel.writeString(this.f994a);
    }
}
