package X;

import O.O;
import android.os.Parcel;
import android.os.Parcelable;

/* JADX INFO: renamed from: X.m, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0182m implements Parcelable {
    public static final Parcelable.Creator<C0182m> CREATOR = new O(6);

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public int f2363a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public int f2364b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public boolean f2365c;

    @Override // android.os.Parcelable
    public final int describeContents() {
        return 0;
    }

    @Override // android.os.Parcelable
    public final void writeToParcel(Parcel parcel, int i4) {
        parcel.writeInt(this.f2363a);
        parcel.writeInt(this.f2364b);
        parcel.writeInt(this.f2365c ? 1 : 0);
    }
}
