package M0;

import a.AbstractC0184a;
import android.os.Parcel;
import android.os.Parcelable;
import java.util.Arrays;

/* JADX INFO: loaded from: classes.dex */
public final class P extends A0.a {
    public static final Parcelable.Creator<P> CREATOR = new D0.c(11);

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final long f976a;

    public P(long j4) {
        this.f976a = Long.valueOf(j4).longValue();
    }

    public final boolean equals(Object obj) {
        return (obj instanceof P) && this.f976a == ((P) obj).f976a;
    }

    public final int hashCode() {
        return Arrays.hashCode(new Object[]{Long.valueOf(this.f976a)});
    }

    @Override // android.os.Parcelable
    public final void writeToParcel(Parcel parcel, int i4) {
        int iM0 = AbstractC0184a.m0(20293, parcel);
        AbstractC0184a.o0(parcel, 1, 8);
        parcel.writeLong(this.f976a);
        AbstractC0184a.n0(iM0, parcel);
    }
}
