package M0;

import a.AbstractC0184a;
import android.os.Parcel;
import android.os.Parcelable;
import java.util.Arrays;

/* JADX INFO: loaded from: classes.dex */
public final class Z extends A0.a {
    public static final Parcelable.Creator<Z> CREATOR = new W(14);

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final long f987a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final byte[] f988b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final byte[] f989c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final byte[] f990d;

    public Z(long j4, byte[] bArr, byte[] bArr2, byte[] bArr3) {
        this.f987a = j4;
        com.google.android.gms.common.internal.F.g(bArr);
        this.f988b = bArr;
        com.google.android.gms.common.internal.F.g(bArr2);
        this.f989c = bArr2;
        com.google.android.gms.common.internal.F.g(bArr3);
        this.f990d = bArr3;
    }

    public final boolean equals(Object obj) {
        if (!(obj instanceof Z)) {
            return false;
        }
        Z z4 = (Z) obj;
        return this.f987a == z4.f987a && Arrays.equals(this.f988b, z4.f988b) && Arrays.equals(this.f989c, z4.f989c) && Arrays.equals(this.f990d, z4.f990d);
    }

    public final int hashCode() {
        return Arrays.hashCode(new Object[]{Long.valueOf(this.f987a), this.f988b, this.f989c, this.f990d});
    }

    @Override // android.os.Parcelable
    public final void writeToParcel(Parcel parcel, int i4) {
        int iM0 = AbstractC0184a.m0(20293, parcel);
        AbstractC0184a.o0(parcel, 1, 8);
        parcel.writeLong(this.f987a);
        AbstractC0184a.c0(parcel, 2, this.f988b, false);
        AbstractC0184a.c0(parcel, 3, this.f989c, false);
        AbstractC0184a.c0(parcel, 4, this.f990d, false);
        AbstractC0184a.n0(iM0, parcel);
    }
}
