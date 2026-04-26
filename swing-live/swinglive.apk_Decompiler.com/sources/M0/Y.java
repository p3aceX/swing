package M0;

import a.AbstractC0184a;
import android.os.Parcel;
import android.os.Parcelable;
import java.util.Arrays;

/* JADX INFO: loaded from: classes.dex */
public final class Y extends A0.a {
    public static final Parcelable.Creator<Y> CREATOR = new W(6);

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final boolean f985a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final byte[] f986b;

    public Y(byte[] bArr, boolean z4) {
        this.f985a = z4;
        this.f986b = bArr;
    }

    public final boolean equals(Object obj) {
        if (!(obj instanceof Y)) {
            return false;
        }
        Y y4 = (Y) obj;
        return this.f985a == y4.f985a && Arrays.equals(this.f986b, y4.f986b);
    }

    public final int hashCode() {
        return Arrays.hashCode(new Object[]{Boolean.valueOf(this.f985a), this.f986b});
    }

    @Override // android.os.Parcelable
    public final void writeToParcel(Parcel parcel, int i4) {
        int iM0 = AbstractC0184a.m0(20293, parcel);
        AbstractC0184a.o0(parcel, 1, 4);
        parcel.writeInt(this.f985a ? 1 : 0);
        AbstractC0184a.c0(parcel, 2, this.f986b, false);
        AbstractC0184a.n0(iM0, parcel);
    }
}
