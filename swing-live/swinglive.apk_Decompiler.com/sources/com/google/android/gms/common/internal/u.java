package com.google.android.gms.common.internal;

import a.AbstractC0184a;
import android.os.Parcel;
import android.os.Parcelable;

/* JADX INFO: loaded from: classes.dex */
public final class u extends A0.a {
    public static final Parcelable.Creator<u> CREATOR = new O.O(15);

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final int f3602a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final boolean f3603b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final boolean f3604c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final int f3605d;
    public final int e;

    public u(int i4, boolean z4, boolean z5, int i5, int i6) {
        this.f3602a = i4;
        this.f3603b = z4;
        this.f3604c = z5;
        this.f3605d = i5;
        this.e = i6;
    }

    @Override // android.os.Parcelable
    public final void writeToParcel(Parcel parcel, int i4) {
        int iM0 = AbstractC0184a.m0(20293, parcel);
        AbstractC0184a.o0(parcel, 1, 4);
        parcel.writeInt(this.f3602a);
        AbstractC0184a.o0(parcel, 2, 4);
        parcel.writeInt(this.f3603b ? 1 : 0);
        AbstractC0184a.o0(parcel, 3, 4);
        parcel.writeInt(this.f3604c ? 1 : 0);
        AbstractC0184a.o0(parcel, 4, 4);
        parcel.writeInt(this.f3605d);
        AbstractC0184a.o0(parcel, 5, 4);
        parcel.writeInt(this.e);
        AbstractC0184a.n0(iM0, parcel);
    }
}
