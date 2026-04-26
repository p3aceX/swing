package com.google.android.gms.common.internal;

import a.AbstractC0184a;
import android.os.Bundle;
import android.os.Parcel;
import android.os.Parcelable;
import z0.C0773d;

/* JADX INFO: loaded from: classes.dex */
public final class L extends A0.a {
    public static final Parcelable.Creator<L> CREATOR = new O.O(16);

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public Bundle f3530a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public C0773d[] f3531b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public int f3532c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public C0286i f3533d;

    @Override // android.os.Parcelable
    public final void writeToParcel(Parcel parcel, int i4) {
        int iM0 = AbstractC0184a.m0(20293, parcel);
        AbstractC0184a.b0(parcel, 1, this.f3530a, false);
        AbstractC0184a.k0(parcel, 2, this.f3531b, i4);
        AbstractC0184a.o0(parcel, 3, 4);
        parcel.writeInt(this.f3532c);
        AbstractC0184a.h0(parcel, 4, this.f3533d, i4, false);
        AbstractC0184a.n0(iM0, parcel);
    }
}
