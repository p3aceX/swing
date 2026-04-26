package M0;

import a.AbstractC0184a;
import android.os.Parcel;
import android.os.Parcelable;
import java.util.Arrays;

/* JADX INFO: loaded from: classes.dex */
public final class Q extends A0.a {
    public static final Parcelable.Creator<Q> CREATOR = new D0.c(12);

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final boolean f977a;

    public Q(boolean z4) {
        this.f977a = Boolean.valueOf(z4).booleanValue();
    }

    public final boolean equals(Object obj) {
        return (obj instanceof Q) && this.f977a == ((Q) obj).f977a;
    }

    public final int hashCode() {
        return Arrays.hashCode(new Object[]{Boolean.valueOf(this.f977a)});
    }

    @Override // android.os.Parcelable
    public final void writeToParcel(Parcel parcel, int i4) {
        int iM0 = AbstractC0184a.m0(20293, parcel);
        AbstractC0184a.o0(parcel, 1, 4);
        parcel.writeInt(this.f977a ? 1 : 0);
        AbstractC0184a.n0(iM0, parcel);
    }
}
