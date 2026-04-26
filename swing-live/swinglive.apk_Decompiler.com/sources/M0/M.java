package M0;

import a.AbstractC0184a;
import android.os.Parcel;
import android.os.Parcelable;
import java.util.Arrays;

/* JADX INFO: loaded from: classes.dex */
public final class M extends A0.a {
    public static final Parcelable.Creator<M> CREATOR = new D0.c(27);

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final boolean f971a;

    public M(boolean z4) {
        this.f971a = z4;
    }

    public final boolean equals(Object obj) {
        return (obj instanceof M) && this.f971a == ((M) obj).f971a;
    }

    public final int hashCode() {
        return Arrays.hashCode(new Object[]{Boolean.valueOf(this.f971a)});
    }

    @Override // android.os.Parcelable
    public final void writeToParcel(Parcel parcel, int i4) {
        int iM0 = AbstractC0184a.m0(20293, parcel);
        AbstractC0184a.o0(parcel, 1, 4);
        parcel.writeInt(this.f971a ? 1 : 0);
        AbstractC0184a.n0(iM0, parcel);
    }
}
