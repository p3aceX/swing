package com.google.android.gms.common.internal;

import a.AbstractC0184a;
import android.os.Parcel;
import android.os.Parcelable;

/* JADX INFO: renamed from: com.google.android.gms.common.internal.q, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0294q extends A0.a {
    public static final Parcelable.Creator<C0294q> CREATOR = new O.O(12);

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final int f3588a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final int f3589b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final int f3590c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final long f3591d;
    public final long e;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public final String f3592f;

    /* JADX INFO: renamed from: m, reason: collision with root package name */
    public final String f3593m;

    /* JADX INFO: renamed from: n, reason: collision with root package name */
    public final int f3594n;

    /* JADX INFO: renamed from: o, reason: collision with root package name */
    public final int f3595o;

    public C0294q(int i4, int i5, int i6, long j4, long j5, String str, String str2, int i7, int i8) {
        this.f3588a = i4;
        this.f3589b = i5;
        this.f3590c = i6;
        this.f3591d = j4;
        this.e = j5;
        this.f3592f = str;
        this.f3593m = str2;
        this.f3594n = i7;
        this.f3595o = i8;
    }

    @Override // android.os.Parcelable
    public final void writeToParcel(Parcel parcel, int i4) {
        int iM0 = AbstractC0184a.m0(20293, parcel);
        AbstractC0184a.o0(parcel, 1, 4);
        parcel.writeInt(this.f3588a);
        AbstractC0184a.o0(parcel, 2, 4);
        parcel.writeInt(this.f3589b);
        AbstractC0184a.o0(parcel, 3, 4);
        parcel.writeInt(this.f3590c);
        AbstractC0184a.o0(parcel, 4, 8);
        parcel.writeLong(this.f3591d);
        AbstractC0184a.o0(parcel, 5, 8);
        parcel.writeLong(this.e);
        AbstractC0184a.i0(parcel, 6, this.f3592f, false);
        AbstractC0184a.i0(parcel, 7, this.f3593m, false);
        AbstractC0184a.o0(parcel, 8, 4);
        parcel.writeInt(this.f3594n);
        AbstractC0184a.o0(parcel, 9, 4);
        parcel.writeInt(this.f3595o);
        AbstractC0184a.n0(iM0, parcel);
    }
}
