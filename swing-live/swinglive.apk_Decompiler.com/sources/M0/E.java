package M0;

import android.os.Parcel;
import android.os.Parcelable;

/* JADX WARN: Failed to restore enum class, 'enum' modifier and super class removed */
/* JADX WARN: Unknown enum class pattern. Please report as an issue! */
/* JADX INFO: loaded from: classes.dex */
public final class E implements Parcelable {

    /* JADX INFO: Fake field, exist only in values array */
    E EF5;

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public static final /* synthetic */ E[] f957a = {new E("PUBLIC_KEY", 0)};
    public static final Parcelable.Creator<E> CREATOR = new D0.c(22);

    public static E a(String str) throws D {
        for (E e : values()) {
            e.getClass();
            if (str.equals("public-key")) {
                return e;
            }
        }
        throw new D(com.google.crypto.tink.shaded.protobuf.S.g("PublicKeyCredentialType ", str, " not supported"));
    }

    public static E valueOf(String str) {
        return (E) Enum.valueOf(E.class, str);
    }

    public static E[] values() {
        return (E[]) f957a.clone();
    }

    @Override // android.os.Parcelable
    public final int describeContents() {
        return 0;
    }

    @Override // java.lang.Enum
    public final String toString() {
        return "public-key";
    }

    @Override // android.os.Parcelable
    public final void writeToParcel(Parcel parcel, int i4) {
        parcel.writeString("public-key");
    }
}
