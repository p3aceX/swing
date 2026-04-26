package w0;

import a.AbstractC0184a;
import android.app.PendingIntent;
import android.os.Bundle;
import android.os.Parcel;
import android.os.Parcelable;

/* JADX INFO: renamed from: w0.b, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0700b extends A0.a {
    public static final Parcelable.Creator<C0700b> CREATOR = new C0701c(1);

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final int f6688a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final PendingIntent f6689b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final int f6690c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final byte[] f6691d;
    public final int e;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public final Bundle f6692f;

    public C0700b(int i4, int i5, PendingIntent pendingIntent, int i6, Bundle bundle, byte[] bArr) {
        this.e = i4;
        this.f6688a = i5;
        this.f6690c = i6;
        this.f6692f = bundle;
        this.f6691d = bArr;
        this.f6689b = pendingIntent;
    }

    @Override // android.os.Parcelable
    public final void writeToParcel(Parcel parcel, int i4) {
        int iM0 = AbstractC0184a.m0(20293, parcel);
        AbstractC0184a.o0(parcel, 1, 4);
        parcel.writeInt(this.f6688a);
        AbstractC0184a.h0(parcel, 2, this.f6689b, i4, false);
        AbstractC0184a.o0(parcel, 3, 4);
        parcel.writeInt(this.f6690c);
        AbstractC0184a.b0(parcel, 4, this.f6692f, false);
        AbstractC0184a.c0(parcel, 5, this.f6691d, false);
        AbstractC0184a.o0(parcel, 1000, 4);
        parcel.writeInt(this.e);
        AbstractC0184a.n0(iM0, parcel);
    }
}
