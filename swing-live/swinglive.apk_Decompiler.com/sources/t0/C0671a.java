package t0;

import a.AbstractC0184a;
import android.os.Parcel;
import android.os.Parcelable;
import j1.C0454D;

/* JADX INFO: renamed from: t0.a, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0671a extends A0.a {
    public static final Parcelable.Creator<C0671a> CREATOR = new C0454D(13);

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final int f6530a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final boolean f6531b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final long f6532c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final boolean f6533d;

    public C0671a(int i4, boolean z4, long j4, boolean z5) {
        this.f6530a = i4;
        this.f6531b = z4;
        this.f6532c = j4;
        this.f6533d = z5;
    }

    @Override // android.os.Parcelable
    public final void writeToParcel(Parcel parcel, int i4) {
        int iM0 = AbstractC0184a.m0(20293, parcel);
        AbstractC0184a.o0(parcel, 1, 4);
        parcel.writeInt(this.f6530a);
        AbstractC0184a.o0(parcel, 2, 4);
        parcel.writeInt(this.f6531b ? 1 : 0);
        AbstractC0184a.o0(parcel, 3, 8);
        parcel.writeLong(this.f6532c);
        AbstractC0184a.o0(parcel, 4, 4);
        parcel.writeInt(this.f6533d ? 1 : 0);
        AbstractC0184a.n0(iM0, parcel);
    }
}
