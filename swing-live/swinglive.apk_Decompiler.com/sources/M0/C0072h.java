package M0;

import a.AbstractC0184a;
import android.os.Parcel;
import android.os.Parcelable;
import java.util.Arrays;

/* JADX INFO: renamed from: M0.h, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0072h extends A0.a {
    public static final Parcelable.Creator<C0072h> CREATOR = new W(4);

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final boolean f1011a;

    public C0072h(boolean z4) {
        this.f1011a = z4;
    }

    public final boolean equals(Object obj) {
        return (obj instanceof C0072h) && this.f1011a == ((C0072h) obj).f1011a;
    }

    public final int hashCode() {
        return Arrays.hashCode(new Object[]{Boolean.valueOf(this.f1011a)});
    }

    @Override // android.os.Parcelable
    public final void writeToParcel(Parcel parcel, int i4) {
        int iM0 = AbstractC0184a.m0(20293, parcel);
        AbstractC0184a.o0(parcel, 1, 4);
        parcel.writeInt(this.f1011a ? 1 : 0);
        AbstractC0184a.n0(iM0, parcel);
    }
}
