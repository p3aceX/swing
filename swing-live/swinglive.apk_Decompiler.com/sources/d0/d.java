package D0;

import a.AbstractC0184a;
import android.os.Parcel;
import android.os.Parcelable;

/* JADX INFO: loaded from: classes.dex */
public final class d extends A0.a {
    public static final Parcelable.Creator<d> CREATOR = new c(2);

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final int f137a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final String f138b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final int f139c;

    public d(int i4, String str, int i5) {
        this.f137a = i4;
        this.f138b = str;
        this.f139c = i5;
    }

    @Override // android.os.Parcelable
    public final void writeToParcel(Parcel parcel, int i4) {
        int iM0 = AbstractC0184a.m0(20293, parcel);
        AbstractC0184a.o0(parcel, 1, 4);
        parcel.writeInt(this.f137a);
        AbstractC0184a.i0(parcel, 2, this.f138b, false);
        AbstractC0184a.o0(parcel, 3, 4);
        parcel.writeInt(this.f139c);
        AbstractC0184a.n0(iM0, parcel);
    }

    public d(String str, int i4) {
        this.f137a = 1;
        this.f138b = str;
        this.f139c = i4;
    }
}
