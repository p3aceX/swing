package D0;

import a.AbstractC0184a;
import android.os.Parcel;
import android.os.Parcelable;

/* JADX INFO: loaded from: classes.dex */
public final class b extends A0.a {
    public static final Parcelable.Creator<b> CREATOR = new c(0);

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final int f134a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final a f135b;

    public b(int i4, a aVar) {
        this.f134a = i4;
        this.f135b = aVar;
    }

    @Override // android.os.Parcelable
    public final void writeToParcel(Parcel parcel, int i4) {
        int iM0 = AbstractC0184a.m0(20293, parcel);
        AbstractC0184a.o0(parcel, 1, 4);
        parcel.writeInt(this.f134a);
        AbstractC0184a.h0(parcel, 2, this.f135b, i4, false);
        AbstractC0184a.n0(iM0, parcel);
    }

    public b(a aVar) {
        this.f134a = 1;
        this.f135b = aVar;
    }
}
