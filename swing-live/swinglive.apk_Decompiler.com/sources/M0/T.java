package M0;

import a.AbstractC0184a;
import android.os.Parcel;
import android.os.Parcelable;
import java.util.Arrays;

/* JADX INFO: loaded from: classes.dex */
public final class T extends A0.a {
    public static final Parcelable.Creator<T> CREATOR = new D0.c(15);

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final byte[][] f979a;

    public T(byte[][] bArr) {
        com.google.android.gms.common.internal.F.b(bArr != null);
        com.google.android.gms.common.internal.F.b(1 == ((bArr.length & 1) ^ 1));
        int i4 = 0;
        while (i4 < bArr.length) {
            com.google.android.gms.common.internal.F.b(i4 == 0 || bArr[i4] != null);
            int i5 = i4 + 1;
            com.google.android.gms.common.internal.F.b(bArr[i5] != null);
            int length = bArr[i5].length;
            com.google.android.gms.common.internal.F.b(length == 32 || length == 64);
            i4 += 2;
        }
        this.f979a = bArr;
    }

    public final boolean equals(Object obj) {
        if (obj instanceof T) {
            return Arrays.deepEquals(this.f979a, ((T) obj).f979a);
        }
        return false;
    }

    public final int hashCode() {
        int iHashCode = 0;
        for (byte[] bArr : this.f979a) {
            iHashCode ^= Arrays.hashCode(new Object[]{bArr});
        }
        return iHashCode;
    }

    @Override // android.os.Parcelable
    public final void writeToParcel(Parcel parcel, int i4) {
        int iM0 = AbstractC0184a.m0(20293, parcel);
        byte[][] bArr = this.f979a;
        if (bArr != null) {
            int iM02 = AbstractC0184a.m0(1, parcel);
            parcel.writeInt(bArr.length);
            for (byte[] bArr2 : bArr) {
                parcel.writeByteArray(bArr2);
            }
            AbstractC0184a.n0(iM02, parcel);
        }
        AbstractC0184a.n0(iM0, parcel);
    }
}
