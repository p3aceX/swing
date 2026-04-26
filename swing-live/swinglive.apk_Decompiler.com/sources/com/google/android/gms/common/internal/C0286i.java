package com.google.android.gms.common.internal;

import a.AbstractC0184a;
import android.os.Parcel;
import android.os.Parcelable;

/* JADX INFO: renamed from: com.google.android.gms.common.internal.i, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0286i extends A0.a {
    public static final Parcelable.Creator<C0286i> CREATOR = new O.O(17);

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final u f3563a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final boolean f3564b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final boolean f3565c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final int[] f3566d;
    public final int e;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public final int[] f3567f;

    public C0286i(u uVar, boolean z4, boolean z5, int[] iArr, int i4, int[] iArr2) {
        this.f3563a = uVar;
        this.f3564b = z4;
        this.f3565c = z5;
        this.f3566d = iArr;
        this.e = i4;
        this.f3567f = iArr2;
    }

    @Override // android.os.Parcelable
    public final void writeToParcel(Parcel parcel, int i4) {
        int iM0 = AbstractC0184a.m0(20293, parcel);
        AbstractC0184a.h0(parcel, 1, this.f3563a, i4, false);
        AbstractC0184a.o0(parcel, 2, 4);
        parcel.writeInt(this.f3564b ? 1 : 0);
        AbstractC0184a.o0(parcel, 3, 4);
        parcel.writeInt(this.f3565c ? 1 : 0);
        AbstractC0184a.e0(parcel, 4, this.f3566d, false);
        AbstractC0184a.o0(parcel, 5, 4);
        parcel.writeInt(this.e);
        AbstractC0184a.e0(parcel, 6, this.f3567f, false);
        AbstractC0184a.n0(iM0, parcel);
    }
}
