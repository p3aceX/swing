package M0;

import a.AbstractC0184a;
import android.os.Parcel;
import android.os.Parcelable;
import java.util.Arrays;

/* JADX INFO: loaded from: classes.dex */
public final class X extends A0.a {
    public static final Parcelable.Creator<X> CREATOR = new W(5);

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final byte[] f983a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final byte[] f984b;

    public X(byte[] bArr, byte[] bArr2) {
        this.f983a = bArr;
        this.f984b = bArr2;
    }

    public final boolean equals(Object obj) {
        if (!(obj instanceof X)) {
            return false;
        }
        X x4 = (X) obj;
        return Arrays.equals(this.f983a, x4.f983a) && Arrays.equals(this.f984b, x4.f984b);
    }

    public final int hashCode() {
        return Arrays.hashCode(new Object[]{this.f983a, this.f984b});
    }

    @Override // android.os.Parcelable
    public final void writeToParcel(Parcel parcel, int i4) {
        int iM0 = AbstractC0184a.m0(20293, parcel);
        AbstractC0184a.c0(parcel, 1, this.f983a, false);
        AbstractC0184a.c0(parcel, 2, this.f984b, false);
        AbstractC0184a.n0(iM0, parcel);
    }
}
