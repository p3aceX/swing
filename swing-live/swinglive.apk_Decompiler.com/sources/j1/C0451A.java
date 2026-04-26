package j1;

import O.O;
import a.AbstractC0184a;
import android.net.Uri;
import android.os.Parcel;
import android.os.Parcelable;

/* JADX INFO: renamed from: j1.A, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0451A extends A0.a {
    public static final Parcelable.Creator<C0451A> CREATOR = new O(29);

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public String f5156a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public String f5157b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public boolean f5158c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public boolean f5159d;
    public Uri e;

    @Override // android.os.Parcelable
    public final void writeToParcel(Parcel parcel, int i4) {
        int iM0 = AbstractC0184a.m0(20293, parcel);
        AbstractC0184a.i0(parcel, 2, this.f5156a, false);
        AbstractC0184a.i0(parcel, 3, this.f5157b, false);
        AbstractC0184a.o0(parcel, 4, 4);
        parcel.writeInt(this.f5158c ? 1 : 0);
        AbstractC0184a.o0(parcel, 5, 4);
        parcel.writeInt(this.f5159d ? 1 : 0);
        AbstractC0184a.n0(iM0, parcel);
    }
}
