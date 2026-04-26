package w0;

import a.AbstractC0184a;
import android.os.Bundle;
import android.os.Parcel;
import android.os.Parcelable;

/* JADX INFO: renamed from: w0.a, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0699a extends A0.a {
    public static final Parcelable.Creator<C0699a> CREATOR = new C0701c(0);

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final String f6683a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final int f6684b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final long f6685c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final byte[] f6686d;
    public final int e;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public final Bundle f6687f;

    public C0699a(int i4, String str, int i5, long j4, byte[] bArr, Bundle bundle) {
        this.e = i4;
        this.f6683a = str;
        this.f6684b = i5;
        this.f6685c = j4;
        this.f6686d = bArr;
        this.f6687f = bundle;
    }

    public final String toString() {
        return "ProxyRequest[ url: " + this.f6683a + ", method: " + this.f6684b + " ]";
    }

    @Override // android.os.Parcelable
    public final void writeToParcel(Parcel parcel, int i4) {
        int iM0 = AbstractC0184a.m0(20293, parcel);
        AbstractC0184a.i0(parcel, 1, this.f6683a, false);
        AbstractC0184a.o0(parcel, 2, 4);
        parcel.writeInt(this.f6684b);
        AbstractC0184a.o0(parcel, 3, 8);
        parcel.writeLong(this.f6685c);
        AbstractC0184a.c0(parcel, 4, this.f6686d, false);
        AbstractC0184a.b0(parcel, 5, this.f6687f, false);
        AbstractC0184a.o0(parcel, 1000, 4);
        parcel.writeInt(this.e);
        AbstractC0184a.n0(iM0, parcel);
    }
}
