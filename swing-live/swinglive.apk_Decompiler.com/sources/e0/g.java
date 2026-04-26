package E0;

import a.AbstractC0184a;
import android.os.Parcel;
import android.os.Parcelable;

/* JADX INFO: loaded from: classes.dex */
public final class g extends A0.a {
    public static final Parcelable.Creator<g> CREATOR = new D0.c(3);

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final int f297a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final String f298b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final a f299c;

    public g(a aVar, String str) {
        this.f297a = 1;
        this.f298b = str;
        this.f299c = aVar;
    }

    @Override // android.os.Parcelable
    public final void writeToParcel(Parcel parcel, int i4) {
        int iM0 = AbstractC0184a.m0(20293, parcel);
        AbstractC0184a.o0(parcel, 1, 4);
        parcel.writeInt(this.f297a);
        AbstractC0184a.i0(parcel, 2, this.f298b, false);
        AbstractC0184a.h0(parcel, 3, this.f299c, i4, false);
        AbstractC0184a.n0(iM0, parcel);
    }

    public g(a aVar, String str, int i4) {
        this.f297a = i4;
        this.f298b = str;
        this.f299c = aVar;
    }
}
