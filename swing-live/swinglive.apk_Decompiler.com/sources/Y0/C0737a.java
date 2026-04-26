package y0;

import a.AbstractC0184a;
import android.os.Bundle;
import android.os.Parcel;
import android.os.Parcelable;
import w0.C0701c;

/* JADX INFO: renamed from: y0.a, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0737a extends A0.a {
    public static final Parcelable.Creator<C0737a> CREATOR = new C0701c(2);

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final int f6803a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final int f6804b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final Bundle f6805c;

    public C0737a(int i4, int i5, Bundle bundle) {
        this.f6803a = i4;
        this.f6804b = i5;
        this.f6805c = bundle;
    }

    @Override // android.os.Parcelable
    public final void writeToParcel(Parcel parcel, int i4) {
        int iM0 = AbstractC0184a.m0(20293, parcel);
        AbstractC0184a.o0(parcel, 1, 4);
        parcel.writeInt(this.f6803a);
        AbstractC0184a.o0(parcel, 2, 4);
        parcel.writeInt(this.f6804b);
        AbstractC0184a.b0(parcel, 3, this.f6805c, false);
        AbstractC0184a.n0(iM0, parcel);
    }
}
